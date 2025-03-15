package org.example.validationapplication.ValidationBase;

import net.sf.saxon.s9api.SaxonApiException;
import org.example.validationapplication.Utils.DocumentType;
import org.example.validationapplication.Utils.ValidationResultDTO;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.nio.file.Path;

public interface IValidation {

    ValidationResultDTO schemaValidation(MultipartFile file, Path xsdFilePath) throws IOException, SAXException;

    ValidationResultDTO schematronValidation(MultipartFile file, Path xsltFilePath) throws IOException, SaxonApiException;

    ValidationResultDTO allValidation(MultipartFile file, Path xsdFilePath, Path xsltFilePath) throws IOException, SaxonApiException, SAXException;
}
