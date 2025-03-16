package org.example.validationapplication.ValidationBase;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XsltTransformer;
import org.example.validationapplication.SchemaSchematronBase.SchematronConfig;
import org.example.validationapplication.Utils.Unzip;
import org.example.validationapplication.Utils.ValidationResultDTO;
import org.example.validationapplication.Utils.ValidationType;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.SAXException;
import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

public class Validation implements IValidation {

    public String xmlString;

    @Override
    public ValidationResultDTO schemaValidation(MultipartFile file, Path xsdFilePath) throws IOException, SAXException {
        try {
            if (file.getOriginalFilename().endsWith(".zip")) {
                xmlString = Unzip.extractXml(file);
            } else {
                xmlString = new String(file.getBytes(), StandardCharsets.UTF_8);
            }

            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            Schema schema = factory.newSchema(new File(xsdFilePath.toString()));
            Validator validator = schema.newValidator();
            validator.validate(new StreamSource(new StringReader(xmlString)));

            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schema;
                    this.schemaValidationStatus = true;
                    this.schemaValidationMessage = "Şema Doğrulaması Başarılı.";
                }
            };

        } catch (IOException e) {
            System.out.println("Dosya okuma sırasında hata meydana geldi.!!!" + e.getMessage());
            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schema;
                    this.schemaValidationStatus = false;
                    this.exceptionMessage = e.getMessage();
                }
            };
        } catch (SAXException e) {
            System.out.println("Şema doğrulaması sırasında bir hata meydana geldi." + e.getMessage());
            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schema;
                    this.schemaValidationStatus = false;
                    this.exceptionMessage = e.getMessage();
                }
            };
        }
    }

    @Override
    public ValidationResultDTO schematronValidation(MultipartFile file, Path xsltFilePath) throws
            IOException, SaxonApiException {
        XsltTransformer xsltTransformer = SchematronConfig.getInstance().getSchematronConfig(xsltFilePath);
        if (file.getOriginalFilename().endsWith(".zip")) {
            xmlString = Unzip.extractXml(file);
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
                    this.schematronValidationMessage = "Şematron Kontrolü Başarılı.";
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
    public ValidationResultDTO allValidation(MultipartFile file, Path xsdFilePath, Path xsltFilePath) {

        ValidationResultDTO validationResultDTO = new ValidationResultDTO();
        try {
            ValidationResultDTO xsdValidationResult = schemaValidation(file, xsdFilePath);
            ValidationResultDTO xsltValidationResult = schematronValidation(file, xsltFilePath);

            validationResultDTO.validationType = ValidationType.All;
            validationResultDTO.schemaValidationStatus = xsdValidationResult.schemaValidationStatus;
            validationResultDTO.schemaValidationMessage = xsdValidationResult.schemaValidationMessage;
            validationResultDTO.schematronValidationStatus = xsltValidationResult.schematronValidationStatus;
            validationResultDTO.schematronValidationMessage = xsltValidationResult.schematronValidationMessage;

        } catch (IOException e) {
            System.out.println("Dosya okuma/yazma işlemi başarısız.:" + e.getMessage());
            validationResultDTO.validationType = ValidationType.All;
            validationResultDTO.exceptionMessage = e.getMessage();
            return validationResultDTO;
        } catch (SAXException e) {
            System.out.println("Şema Doğrulaması Sırasında bir hata meydana geldi.:" + e.getMessage());
            validationResultDTO.validationType = ValidationType.All;
            validationResultDTO.exceptionMessage = e.getMessage();
            return validationResultDTO;
        } catch (SaxonApiException e) {
            System.out.println("Şematron Kontrolü Sırasında bir hata meydana geldi.:" + e.getMessage());
            validationResultDTO.validationType = ValidationType.All;
            validationResultDTO.exceptionMessage = e.getMessage();
        }
        return validationResultDTO;
    }
}

