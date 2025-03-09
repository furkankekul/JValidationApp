package org.example.validationapplication.ValidationBase;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XsltTransformer;
import org.example.validationapplication.SchematronBase.SchematronConfig;
import org.example.validationapplication.Utils.DocumentType;
import org.example.validationapplication.Utils.Unzip;
import org.example.validationapplication.Utils.ValidationResultDTO;
import org.example.validationapplication.Utils.ValidationType;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

public class Validation implements IValidation {

    public String xmlString;

    @Override
    public void schemaValidation(String xmlString, DocumentType documentType) {

    }

    @Override
    public ValidationResultDTO schematronValidation(MultipartFile file, Path xsltFilePath) throws IOException, SaxonApiException {
        XsltTransformer xsltTransformer = SchematronConfig.getInstance().getSchematronConfig(xsltFilePath);
        if (file.getOriginalFilename().endsWith(".zip")) {
            xmlString = Unzip.extractZip(file);
        } else {
            xmlString = new String(file.getBytes(), StandardCharsets.UTF_8);
        }

        String result = SchematronConfig.getInstance().getSchematronControlResult(xmlString, xsltTransformer);
        String finalResult = result.replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "");
        if (finalResult.equals("")) {
            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schematron;
                    this.schematronValidationStatus = true;
                    this.schematronValidationMessage = finalResult;
                }
            };
        }
        return new ValidationResultDTO() {
            {
                this.validationType = ValidationType.Schematron;
                this.schematronValidationStatus = false;
                this.schematronValidationMessage = finalResult;
            }
        };
    }

    @Override
    public void allValidation(String xmlString, DocumentType documentType) {

    }
}
