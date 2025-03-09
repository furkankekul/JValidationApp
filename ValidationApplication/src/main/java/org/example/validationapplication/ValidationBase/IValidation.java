package org.example.validationapplication.ValidationBase;

import net.sf.saxon.s9api.SaxonApiException;
import org.example.validationapplication.Utils.DocumentType;
import org.example.validationapplication.Utils.ValidationResultDTO;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;

public interface IValidation {

    void schemaValidation(String xmlString, DocumentType documentType);

    ValidationResultDTO schematronValidation(MultipartFile file, Path xsltFilePath) throws IOException, SaxonApiException;

    void allValidation(String xmlString, DocumentType documentType);
}
