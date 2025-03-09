package org.example.validationapplication.Utils;

import org.springframework.web.multipart.MultipartFile;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
public class Unzip {


    public static String extractZip(MultipartFile file) throws IOException {
        try (ZipInputStream zipInputStream = new ZipInputStream(file.getInputStream(), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            StringBuilder extractedContent = new StringBuilder();

            while ((entry = zipInputStream.getNextEntry()) != null) {
                // Eğer ZIP içindeki eleman bir klasör değilse, içeriğini oku
                if (!entry.isDirectory()) {
                    extractedContent.append(readZipEntry(zipInputStream));
                }
                zipInputStream.closeEntry();
            }

            return extractedContent.toString();
        }
    }

    private static String readZipEntry(InputStream inputStream) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8));
        StringBuilder content = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            content.append(line).append("\n");
        }
        return content.toString();
    }
}
