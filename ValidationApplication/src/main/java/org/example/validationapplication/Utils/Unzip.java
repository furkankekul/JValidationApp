package org.example.validationapplication.Utils;

import org.springframework.web.multipart.MultipartFile;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
public class Unzip {

    public static String extractXml(MultipartFile file) throws IOException {
        try (ZipInputStream zipInputStream = new ZipInputStream(file.getInputStream(), StandardCharsets.UTF_8)) {
            ZipEntry entry;

            while ((entry = zipInputStream.getNextEntry()) != null) {
                if (!entry.isDirectory() && entry.getName().endsWith(".xml")) {
                    return readZipEntry(zipInputStream);
                }
            }
        }
        return null;
    }

    private static String readZipEntry(InputStream inputStream) throws IOException {
        StringWriter writer = new StringWriter();
        char[] buffer = new char[4096];
        try (Reader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            int length;
            while ((length = reader.read(buffer)) != -1) {
                writer.write(buffer, 0, length);
            }
        }
        return writer.toString();
    }
}
