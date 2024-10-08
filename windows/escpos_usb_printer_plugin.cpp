﻿#include "escpos_usb_printer_plugin.h"

// This must be included before many other Windows headers.
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cstdint>
#include <sstream>
#include <SDKDDKVer.h>
#include <Windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <limits>
#include <iomanip>
#include <string>
#include "utilities.h"
#include "PosPrinterEx.h"
#include "json.hpp"
#include <unordered_map>

// Define printer commands as constants
constexpr uint8_t ESC_CHAR = 0x1B;
constexpr uint8_t GS = 0x1D;
std::vector<uint8_t> LINE_FEED = {0x0A};
std::vector<uint8_t> CUT_PAPER = {GS, 0x56, 0x00};
std::vector<uint8_t> INIT_PRINTER = {ESC_CHAR, 0x40};
std::vector<uint8_t> SELECT_BIT_IMAGE_MODE = {ESC_CHAR, 0x2A, 33};
std::vector<uint8_t> SET_LINE_SPACE_24 = {ESC_CHAR, 0x33, 24};
std::vector<uint8_t> SET_SPAIN_CHARSET = {ESC_CHAR, 0x74, 0x02};
std::vector<uint8_t> enye = {0xA4};
std::string ROW_MIDDLE_LINES = "------------------------------------------------"; // 48 carecteres de ancho;

// Spacing values for product columns
const int width_quantity = 8;
const int width_name = 24;
const int width_price = 16;

using json = nlohmann::json;

PpUsbPtr m_ppStream = nullptr;

bool isStartOfSequenceMultibyte(uint8_t byte)
{
    // Verify if the 2 higher bits are equal to 11.
    return (byte & 0xC0) == 0xC0;
}

struct PairHash
{
    size_t operator()(const std::pair<uint8_t, uint8_t> &p) const
    {
        return std::hash<uint8_t>()(p.first) ^ std::hash<uint8_t>()(p.second);
    }
};

void convertUtf8ToCp437(std::vector<uint8_t> &data)
{
    std::unordered_map<std::pair<uint8_t, uint8_t>, uint8_t, PairHash> utf8ToCp437Map = {
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xB1)}, static_cast<uint8_t>(0xA4)}, // ñ
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x91)}, static_cast<uint8_t>(0xA5)}, // Ñ
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xA1)}, static_cast<uint8_t>(0xA0)}, // á
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x81)}, static_cast<uint8_t>(0x41)}, // Á
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xA4)}, static_cast<uint8_t>(0x84)}, // ä
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x84)}, static_cast<uint8_t>(0x8E)}, // Ä
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xA9)}, static_cast<uint8_t>(0x82)}, // é
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x89)}, static_cast<uint8_t>(0x90)}, // É
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xAB)}, static_cast<uint8_t>(0x89)}, // ë
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x8B)}, static_cast<uint8_t>(0x45)}, // Ë
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xAD)}, static_cast<uint8_t>(0xA1)}, // í
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x8D)}, static_cast<uint8_t>(0x49)}, // Í
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xAF)}, static_cast<uint8_t>(0x8B)}, // ï
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x8F)}, static_cast<uint8_t>(0x49)}, // Ï
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xB3)}, static_cast<uint8_t>(0xA2)}, // ó
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x93)}, static_cast<uint8_t>(0x4F)}, // Ó
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xB6)}, static_cast<uint8_t>(0x94)}, // ö
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x96)}, static_cast<uint8_t>(0x4F)}, // Ö
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xBA)}, static_cast<uint8_t>(0xA3)}, // ú
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x9A)}, static_cast<uint8_t>(0x55)}, // Ú
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0xBC)}, static_cast<uint8_t>(0x81)}, // ü
        {{static_cast<uint8_t>(0xC3), static_cast<uint8_t>(0x9C)}, static_cast<uint8_t>(0x55)}, // Ü
    };
    std::vector<uint8_t> convertedData;
    for (size_t i = 0; i < data.size(); ++i)
    {
        if (isStartOfSequenceMultibyte(data[i]))
        {
            // manage multibyte sequence
            auto it = utf8ToCp437Map.find({data[i], data[i + 1]});
            if (it != utf8ToCp437Map.end())
            {
                convertedData.push_back(it->second);
                i++; // Head to the second byte in the sequence
            }
            else
            {
                i++;
            }
        }
        else
        {
            convertedData.push_back(data[i]);
        }
    }
    data = std::move(convertedData);
}

// Mandar comandos a la impresora
void write_to_printer(const std::vector<uint8_t> &data)
{
    if (m_ppStream)
    {
        m_ppStream->write(reinterpret_cast<const char *>(data.data()), static_cast<int>(data.size()));
    }
}

// Convertir string a uint8 y mandar comando
void write_text_to_printer(const std::string &text)
{
    std::vector<uint8_t> data(text.begin(), text.end());
    convertUtf8ToCp437(data);
    write_to_printer(data);
}

// Funcion para leer los pixeles de una imagen BMP
std::vector<std::vector<uint32_t>> readBMP(const std::vector<uint8_t> &buffer)
{

    if (buffer.size() < 54)
    {
        throw std::runtime_error("Invalid BMP file.");
    }

    // Los pixeles empiezan en el byte 54
    int pixelOffset = buffer[10] | (buffer[11] << 8) | (buffer[12] << 16) | (buffer[13] << 24);
    int width = buffer[18] | (buffer[19] << 8) | (buffer[20] << 16) | (buffer[21] << 24);
    int height = buffer[22] | (buffer[23] << 8) | (buffer[24] << 16) | (buffer[25] << 24);
    bool is24Bit = buffer[28] == 24; // Asumiendo que es un BMP de 24 bits

    if (!is24Bit)
    {
        throw std::runtime_error("Only 24-bit BMP files are supported.");
    }

    std::vector<std::vector<uint32_t>> pixels(height, std::vector<uint32_t>(width));

    // Cada fila de pixeles debe alinearse a 4 bytes
    int padding = (4 - (width * 3) % 4) % 4;

    size_t index = pixelOffset;
    for (int y = height - 1; y >= 0; --y)
    { // Empieza desde la ultima fila
        for (int x = 0; x < width; ++x)
        {
            // Los p�xeles en BMP estan en orden BGR, y el canal alfa se asume 255
            unsigned char b = buffer[index++];
            unsigned char g = buffer[index++];
            unsigned char r = buffer[index++];
            uint32_t argb = (255 << 24) | (r << 16) | (g << 8) | b; // ARGB
            pixels[y][x] = argb;
        }
        index += padding; // Saltar los bytes de relleno al final de cada fila
    }

    return pixels;
}

// Funcion para centrar texto segun el ancho del recibo
std::string center_text(const std::string &text)
{
    // Calcular el espacio necesario a la izquierda para centrar el texto
    int space = (48 - (int)text.length()) / 2;
    if (space < 0)
        space = 0; // En caso de que el texto sea mas largo que el ancho

    // Componer el texto centrado con espacios a la izquierda
    std::ostringstream out;
    out << std::setw(space + text.length()) << text;
    return out.str();
}

void print_text_with_centered_last_line(const std::string &text)
{
    std::istringstream words(text);
    std::string word;
    std::string line;
    std::vector<std::string> lines;

    while (words >> word)
    {
        if (line.length() + word.length() + 1 > 48)
        {
            lines.push_back(line);
            line = word;
        }
        else
        {
            if (!line.empty())
                line += " ";
            line += word;
        }
    }
    lines.push_back(line); // Anadir la ultima linea despues del bucle

    // Imprime todas las lineas excepto la ultima
    for (size_t i = 0; i < lines.size() - 1; ++i)
    {
        write_text_to_printer(lines[i] + "\n");
    }

    // Centra y escribe la ultima linea
    std::string last_line = lines.back();
    int space = (48 - (int)last_line.length()) / 2;
    if (space < 0)
        space = 0; // En caso de que el texto sea mas largo que el ancho

    std::string centered_line(space, ' ');
    centered_line += last_line;

    write_text_to_printer(centered_line + "\n");
}

int countCharacters(const std::string &text)
{
    int count = 0;
    for (size_t i = 0; i < text.length(); ++i)
    {
        if ((text[i] & 0xC0) != 0x80)
        {
            count++;
        }
    }
    return count;
}

// Función para formatear y escribir líneas de totales
void print_justify_end(const std::string &label, double value) {
    std::ostringstream total_stream;

    // Formatear el valor con el signo $ y dos decimales
    std::ostringstream price_stream;
    price_stream << "$" << std::fixed << std::setprecision(2) << value;
    std::string price_with_symbol = price_stream.str();

    // Calcular el ancho necesario para el valor para que ocupe 10 espacios
    std::ostringstream price_padded_stream;
    price_padded_stream << std::right << std::setw(10) << price_with_symbol;
    std::string price_padded_str = price_padded_stream.str();

    // Calculamos el ancho total, incluyendo la etiqueta y el precio
    size_t total_length = label.length() + price_padded_str.length();

    // Asegurarse de que la línea total no exceda los 48 caracteres
    total_stream << std::right << std::setw(48 - total_length) << "" << label << price_padded_str << "\n";

    // Enviar la línea formateada al impresor
    write_text_to_printer(total_stream.str());
}

void print_right_justified(const std::string &text, size_t total_width) {
    std::ostringstream stream;

    // Justificar el texto a la derecha con el ancho total especificado
    stream << std::right << std::setw(total_width) << text << "\n";

    // Enviar el texto formateado al impresor
    write_text_to_printer(stream.str());
}

void print_payment_methods(const nlohmann::json &payment_methods) {    
    print_right_justified("Metodos de pago:\n", 48);

    for (const auto &method : payment_methods) {                
        std::string payment_type = method["payment"].get<std::string>();
        double amount = method["amount"].get<double>();        

        print_justify_end(payment_type +":", amount);        
    }
    write_text_to_printer("\n");
}

bool print_json_ticket(const std::string &json_str) {
    auto json = nlohmann::json::parse(json_str);

    std::string branch_name = center_text("Sucursal: " + json["branch"]["name"].get<std::string>()) + "\n\n";
    write_text_to_printer(branch_name);

    std::string branch_rfc = center_text("RFC: " + json["rfc"].get<std::string>() + " Tel: " + json["branch"]["phone"].get<std::string>()) +"\n\n";
    write_text_to_printer(branch_rfc);

    print_text_with_centered_last_line(json["branch"]["address"].get<std::string>());

    std::string order_date = center_text("\n\n"+json["date"].get<std::string>()) + "\n\n";
    write_text_to_printer(order_date);

    // Print Order Number
    std::string order_number;
    if (json["is_offline"].get<bool>()) {
        // if is_offline is true the field is called Folio
        order_number = "\n\nFolio: #" + std::to_string(json["order"].get<int>()) + "\n\n";
    } else {
        // if is_offline is false the field is called Orden
        order_number = "\n\nOrden: #" + std::to_string(json["order"].get<int>()) + "\n\n";
    }
    write_text_to_printer(order_number);

    std::string order_employee = "Cajero: "+json["session"]["user"].get<std::string>() + "\n";
    write_text_to_printer(order_employee);

    std::string order_line = "Caja: "+json["session"]["line"].get<std::string>() + "\n";
    write_text_to_printer(order_line);

    write_text_to_printer(ROW_MIDDLE_LINES);

    write_text_to_printer("Producto             Cantidad             Precio\n\n");

    // Print Products
    for (const auto &product : json["products"]) {
        std::ostringstream line_stream;

        std::string productName = product["product_name"].get<std::string>();
        int quantity = product["quantity"].get<int>();
        double price = product["price"].get<double>();

        // Calcular el ancho de espacio disponible
        int product_name_width = 25; // Ajusta este valor según el tamaño que desees para el nombre del producto
        int quantity_width = 10;     // Ajusta este valor según el tamaño que desees para la cantidad
        int price_width = 12;        // Ajusta este valor según el tamaño que desees para el precio

        // Validar que los tamaños no excedan el ancho total
        if (productName.length() > product_name_width) {
            productName = productName.substr(0, product_name_width);
        }

        // Ajustar el ancho de la cantidad
        std::ostringstream quantity_stream;
        quantity_stream << std::left << std::setw(quantity_width) << quantity;
        std::string quantity_str = quantity_stream.str();

        // Ajustar el ancho del precio
        std::ostringstream price_stream;
        price_stream << "$" << std::fixed << std::setprecision(2) << price;
        std::string price_str = price_stream.str();
        std::ostringstream price_padded_stream;
        price_padded_stream << std::right << std::setw(price_width) << price_str;
        std::string price_padded_str = price_padded_stream.str();

        // Rellenar el ancho de producto_name con espacios en blanco para ajustar la alineación
        std::ostringstream product_stream;
        product_stream << std::left << std::setw(product_name_width) << productName;
        std::string product_str = product_stream.str();

        // Formatear la línea completa
        line_stream << product_str << quantity_str << price_padded_str << "\n\n";

        // Enviar la línea completa al impresor
        write_text_to_printer(line_stream.str());

        // Print modifiers if they exist
        if (product.contains("modifiers")) {
            for (const auto &modifier : product["modifiers"]) {
                std::string modifierName = modifier["name"].get<std::string>();
                int modifierQuantity = modifier.contains("quantity") ? modifier["quantity"].get<int>() : 1;
                double modifierPrice = modifier.contains("price") ? modifier["price"].get<double>() : 0.0;

                // Formatear el modificador
                std::ostringstream modifier_line_stream;

                // Ajustar el nombre del modificador y la cantidad
                std::ostringstream modifier_name_stream;
                modifier_name_stream << std::left << std::setw(product_name_width) << ("    " + modifierName);
                std::string modifier_name_str = modifier_name_stream.str();

                std::ostringstream modifier_quantity_stream;
                modifier_quantity_stream << std::left << std::setw(quantity_width) << modifierQuantity;
                std::string modifier_quantity_str = modifier_quantity_stream.str();

                // Ajustar el precio del modificador
                std::ostringstream modifier_price_stream;
                modifier_price_stream << "$" << std::fixed << std::setprecision(2) << modifierPrice;
                std::string modifier_price_str = modifier_price_stream.str();
                std::ostringstream modifier_price_padded_stream;
                modifier_price_padded_stream << std::right << std::setw(price_width) << modifier_price_str;
                std::string modifier_price_padded_str = modifier_price_padded_stream.str();

                // Formatear la línea completa del modificador
                modifier_line_stream << modifier_name_str << modifier_quantity_str << modifier_price_padded_str << "\n";

                // Enviar la línea completa del modificador al impresor
                write_text_to_printer(modifier_line_stream.str());
            }
        }
    }

    write_text_to_printer("\n\n");
    write_text_to_printer(ROW_MIDDLE_LINES);
    write_text_to_printer("\n\n");

    // Print subtotal, tax, dicount and total
    print_justify_end("Subtotal: ", json["subtotal"].get<double>());
    print_justify_end("Impuesto: ", json["tax"].get<double>());
    print_justify_end("Descuento:", json["discount"].get<double>());
    print_justify_end("Total:    ", json["total"].get<double>());    

    std::string total_in_words = json["total_in_words"].get<std::string>() +" pesos m.n"+"\n";    

    print_right_justified(total_in_words, 48);

   // Imprimir métodos de pago
    print_payment_methods(json["payment_methods"]);
    
    write_text_to_printer(ROW_MIDDLE_LINES);
    write_text_to_printer("\n");
    
    print_text_with_centered_last_line("Si desea facturar su venta, favor de ingresar a la siguiente direcci\xC3\xB3n con los datos de este ticket");

    write_text_to_printer("\n");    

    std::string url_invoice = json["url_invoice"].get<std::string>() + "\n";
    print_text_with_centered_last_line(url_invoice);

    std::vector<uint8_t> cmdFeedPaper = composeCmdFeedPaper(15);
    write_to_printer(cmdFeedPaper);

    std::vector<uint8_t> cmdCut = composeCmdCut(1);
    write_to_printer(cmdCut);

    return true;
}

bool print_json_kitchen_ticket(const std::string &json_str) {
    auto json = nlohmann::json::parse(json_str);

    // Print Order Number
    std::string order_number;
    if (json["is_offline"].get<bool>()) {
        // if is_offline is true the field is called Folio
        order_number = "\n\nFolio: #" + std::to_string(json["order"].get<int>()) + "\n\n";
    } else {
        // if is_offline is false the field is called Orden
        order_number = "\n\nOrden: #" + std::to_string(json["order"].get<int>()) + "\n\n";
    }
    write_text_to_printer("Fecha: " + json["date"].get<std::string>() + "\n\n");

    write_text_to_printer(order_number);

    write_text_to_printer(ROW_MIDDLE_LINES);

    // Print header
    std::string header = "Producto                                Cantidad";
    write_text_to_printer(header + "\n");

    // Print Products
    for (const auto &product : json["products"]) {
        write_text_to_printer("\n");
        std::ostringstream line_stream;

        std::string productName = product["product_name"].get<std::string>();
        int quantity = product["quantity"].get<int>();

        // Calcular el ancho de espacio disponible
        int product_name_width = 43; // Ajusta este valor según el tamaño que desees para el nombre del producto
        int quantity_width = 5;     // Ajusta este valor según el tamaño que desees para la cantidad

        // Validar que los tamaños no excedan el ancho total
        if (productName.length() > product_name_width) {
            productName = productName.substr(0, product_name_width);
        }

        // Ajustar el ancho de la cantidad
        std::ostringstream quantity_stream;
        quantity_stream << std::left << std::setw(quantity_width) << quantity;
        std::string quantity_str = quantity_stream.str();

        // Rellenar el ancho de producto_name con espacios en blanco para ajustar la alineación
        std::ostringstream product_stream;
        product_stream << std::left << std::setw(product_name_width) << productName;
        std::string product_str = product_stream.str();

        // Formatear la línea completa
        line_stream << product_str << quantity_str << "\n";

        // Enviar la línea completa al impresor
        write_text_to_printer(line_stream.str());

        // Print modifiers if they exist
        if (product.contains("modifiers")) {
            for (const auto &modifier : product["modifiers"]) {
                std::string modifierName = modifier["name"].get<std::string>();
                int modifierQuantity = modifier.contains("quantity") ? modifier["quantity"].get<int>() : 1;

                // Formatear el modificador
                std::ostringstream modifier_line_stream;

                // Ajustar el nombre del modificador y la cantidad
                std::ostringstream modifier_name_stream;
                modifier_name_stream << std::left << std::setw(product_name_width) << ("    " + modifierName);
                std::string modifier_name_str = modifier_name_stream.str();

                std::ostringstream modifier_quantity_stream;
                modifier_quantity_stream << std::left << std::setw(quantity_width) << modifierQuantity;
                std::string modifier_quantity_str = modifier_quantity_stream.str();

                // Formatear la línea completa del modificador
                modifier_line_stream << modifier_name_str << modifier_quantity_str << "\n";

                // Enviar la línea completa del modificador al impresor
                write_text_to_printer(modifier_line_stream.str());
            }
        }        
    }

    write_text_to_printer("\n\n");
    write_text_to_printer(ROW_MIDDLE_LINES);
    write_text_to_printer("\n\n");

    std::vector<uint8_t> cmdFeedPaper = composeCmdFeedPaper(15);
    write_to_printer(cmdFeedPaper);

    std::vector<uint8_t> cmdCut = composeCmdCut(1);
    write_to_printer(cmdCut);

    return true;
}


// Function to determine if a pixel's color should be printed
bool should_print_color(uint32_t col)
{
    constexpr uint32_t threshold = 127;
    uint8_t a = (col >> 24) & 0xff;
    if (a != 0xff)
    { // Ignore transparencies
        return false;
    }
    uint8_t r = (col >> 16) & 0xff;
    uint8_t g = (col >> 8) & 0xff;
    uint8_t b = col & 0xff;
    uint32_t luminance = static_cast<uint32_t>(0.299 * r + 0.587 * g + 0.114 * b);
    return luminance < threshold;
}

// Function to recollect slice
std::vector<uint8_t> recollect_slice(int y, int x, const std::vector<std::vector<uint32_t>> &img)
{
    std::vector<uint8_t> slices(3, 0);
    for (int i = 0, yy = y; yy < y + 24 && i < 3; yy += 8, ++i)
    {
        uint8_t slice = 0;
        for (int b = 0; b < 8; ++b)
        {
            int yyy = yy + b;
            if (yyy >= img.size())
            {
                continue;
            }
            uint32_t col = img[yyy][x];
            if (should_print_color(col))
            {
                slice |= 1 << (7 - b);
            }
        }
        slices[i] = slice;
    }
    return slices;
}

// Function to print the image
void print_image(const std::vector<std::vector<uint32_t>> &pixels)
{
    write_to_printer(INIT_PRINTER);
    write_to_printer(SET_LINE_SPACE_24);

    int manualSpaces = 6;                            // Aqui ajustamos la cantidad de espacios en blanco manualmente.
    std::vector<uint8_t> spaces(manualSpaces, 0x20); // Crear un vector con 10 espacios.

    for (size_t y = 0; y < pixels.size(); y += 24)
    {
        // Enviar espacios en blanco al inicio de cada linea
        write_to_printer(spaces);

        write_to_printer(SELECT_BIT_IMAGE_MODE);
        uint16_t width = (uint16_t)pixels[y].size();
        write_to_printer({static_cast<uint8_t>(width & 0xFF), static_cast<uint8_t>((width >> 8) & 0xFF)});

        for (size_t x = 0; x < pixels[y].size(); ++x)
        {
            auto sliceData = recollect_slice(static_cast<int>(y), static_cast<int>(x), pixels);
            write_to_printer(sliceData);
        }

        write_to_printer(LINE_FEED);
    }

    // Avance de papel
    std::vector<uint8_t> cmd = composeCmdFeedPaper(5);
    m_ppStream->write(reinterpret_cast<char *>(cmd.data()), static_cast<int>(cmd.size()));
}

bool loadImageAndPrint(std::vector<uint8_t> imageBytes)
{

    try
    {
        auto pixels = readBMP(imageBytes);
        if (pixels.empty())
        {
            std::cerr << "Error: El archivo de pixeles esta vacio o no se pudo leer." << std::endl;
            return false;
        }
        print_image(pixels); // Utiliza la funcion de impresion que definimos previamente
        return true;
    }
    catch (const std::exception &e)
    {
        std::cerr << "Excepcion capturada: " << e.what() << std::endl;
        return false;
    }
}

bool InitializeUsbService()
{
    if (m_ppStream)
    {
        PpClose(m_ppStream);
        m_ppStream = NULL;
    }
    m_ppStream = PpOpenUsb(); // Devuelve puntero

    if (m_ppStream)
    {
        std::cout << "Conexion establecida.\n";

        write_to_printer(SET_SPAIN_CHARSET);
        return true;
    }
    else
    {
        return false;
    }
}

void DisposeUsbService()
{
    if (m_ppStream)
    {
        PpClose(m_ppStream);
        m_ppStream = NULL;
        std::cout << "Conexion cerrada.\n";
    }
    else
    {
        std::cout << "Hubo un error.\n";
    }
}

bool actionVerify()
{
    if (!m_ppStream)
    {
        std::cout << "No hay interfaz abierta.\n";
        return false;
    }

    return true;
}

std::string GetPrinterStatus()
{
    if (!actionVerify())
    {
        return "Service not initialized";
    }

    m_ppStream->write((char *)g_cmdGetPrinterStatus, (int)RAW_DATA_SIZE(g_cmdGetPrinterStatus));

    uint8_t status = 0;

    int readed = m_ppStream->read((char *)&status, 1);
    std::string statusText;
    if (readed > 0)
    {
        statusText = printerStatusToText(status);
    }
    else
    {
        statusText = "Failed to read from current interface.";
    }
    std::string tag;

    statusText = tag + " " + statusText + "\n";
    return statusText;
}

bool PrintTicket(std::vector<uint8_t> imageBytes, std::string json)
{
    if (loadImageAndPrint(imageBytes) == true)
    {
        if (print_json_ticket(json) == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}

bool PrintKitchenTicket(std::vector<uint8_t> imageBytes, std::string json)
{
    if (loadImageAndPrint(imageBytes) == true)
    {
        if (print_json_kitchen_ticket(json) == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}

namespace escpos_usb_printer
{

    // static
    void EscposUsbPrinterPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "escpos_usb_printer",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<EscposUsbPrinterPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));
    }

    EscposUsbPrinterPlugin::EscposUsbPrinterPlugin() {}

    EscposUsbPrinterPlugin::~EscposUsbPrinterPlugin() {}

    void EscposUsbPrinterPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        bool isUsbServiceInitialized = InitializeUsbService();
        if (method_call.method_name().compare("initService") == 0)
        {
            bool functionResult = InitializeUsbService();
            result->Success(flutter::EncodableValue(functionResult));
        }
        else if (method_call.method_name().compare("getPrinterStatus") == 0)
        {
            std::string functionResult = GetPrinterStatus();
            result->Success(flutter::EncodableValue(functionResult));
        }
        else if (method_call.method_name().compare("printTicket") == 0)
        {
            if (isUsbServiceInitialized == false)
            {
                isUsbServiceInitialized = InitializeUsbService();
            }
            if (isUsbServiceInitialized == false)
            {
                result->Error(
                    "1000",
                    "Printer usb service is not initialized",
                    flutter::EncodableValue("Make sure that the printer is ON and connected to this device"));
                return;
            }
            else
            {
                const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());
                if (!args)
                {
                    result->Error("InvalidArguments", "Expected map as argument");
                    return;
                }
                std::vector<uint8_t> imageBytes;
                auto imageIt = args->find(flutter::EncodableValue("image"));
                const auto &imageVariant = imageIt->second;
                if (std::holds_alternative<std::vector<uint8_t>>(imageVariant))
                {
                    imageBytes = std::get<std::vector<uint8_t>>(imageVariant);
                }
                else
                {
                    result->Error("InvalidArguments", "Expected image list of bytes as argument");
                }

                auto jsonIt = args->find(flutter::EncodableValue("json"));
                if (jsonIt == args->end() || !std::holds_alternative<std::string>(jsonIt->second))
                {
                    result->Error("InvalidArguments", "Expected JSON string as argument");
                    return;
                }

                const std::string &jsonStr = std::get<std::string>(jsonIt->second);
                try
                {
                    bool success = PrintTicket(imageBytes, jsonStr);
                    result->Success(flutter::EncodableValue(success));
                }
                catch (const nlohmann::json::parse_error &e)
                {
                    std::cerr << "JSON parsing error: " << e.what() << '\n';
                    result->Error("InvalidArguments", "Error parsering the JSON");
                }
                catch (const nlohmann::json::type_error &e)
                {
                    std::cerr << "JSON type error: " << e.what() << '\n';
                }
            }
        }
        else if (method_call.method_name().compare("printKitchenTicket") == 0)
        {
            {
                if (isUsbServiceInitialized == false)
                {
                    isUsbServiceInitialized = InitializeUsbService();

                    if (isUsbServiceInitialized == false)
                    {
                        result->Error(
                            "1000",
                            "Printer usb service is not initialized",
                            flutter::EncodableValue("Make sure that the printer is ON and connected to this device"));
                        return;
                    }
                }
                else
                {
                    const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());
                    if (!args)
                    {
                        result->Error("InvalidArguments", "Expected map as argument");
                        return;
                    }
                    std::vector<uint8_t> imageBytes;
                    auto imageIt = args->find(flutter::EncodableValue("image"));
                    const auto &imageVariant = imageIt->second;
                    if (std::holds_alternative<std::vector<uint8_t>>(imageVariant))
                    {
                        imageBytes = std::get<std::vector<uint8_t>>(imageVariant);
                    }
                    else
                    {
                        result->Error("InvalidArguments", "Expected image list of bytes as argument");
                    }

                    auto jsonIt = args->find(flutter::EncodableValue("json"));
                    if (jsonIt == args->end() || !std::holds_alternative<std::string>(jsonIt->second))
                    {
                        result->Error("InvalidArguments", "Expected JSON string as argument");
                        return;
                    }

                    const std::string &jsonStr = std::get<std::string>(jsonIt->second);
                    try
                    {
                        bool success = PrintKitchenTicket(imageBytes, jsonStr);
                        result->Success(flutter::EncodableValue(success));
                    }
                    catch (const nlohmann::json::parse_error &e)
                    {
                        std::cerr << "JSON parsing error: " << e.what() << '\n';
                        result->Error("InvalidArguments", "Error parsering the JSON");
                    }
                    catch (const nlohmann::json::type_error &e)
                    {
                        std::cerr << "JSON type error: " << e.what() << '\n';
                    }
                }
            }
        }
        else
        {
            result->NotImplemented();
        }
    }
} // namespace escpos_usb_printer
