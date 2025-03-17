package org.example.validationapplication.SchemaSchematronBase;

import org.example.validationapplication.Utils.ValidationResultDTO;
import org.example.validationapplication.Utils.ValidationType;
import org.xml.sax.SAXException;
import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public class SchemaConfig {

    private static final SchemaConfig instance = new SchemaConfig();

    private static final SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);

    private static final Map<Path, Schema> cache = new HashMap<>();

    public static SchemaConfig getInstance() {
        return instance;
    }

    public static SchemaFactory getSchemaFactory() {
        return schemaFactory;
    }

    public ValidationResultDTO schemaValidation(String xmlString, Path xsdFilePath) {
        try {
            Schema createdSchemaObj = getCreatedSchemaObj(schemaFactory, xsdFilePath);
            Validator validator = createdSchemaObj.newValidator();
            validator.validate(new StreamSource(new StringReader(xmlString)));
            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schema;
                    this.schemaValidationStatus = true;
                    this.schemaValidationMessage = "Şema Doğrulaması Başarılı.";
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
        } catch (IOException e) {
            System.out.println("Dosya okuma/yazma işlemi yapılırken hata meydana geldi: " + e.getMessage());
            return new ValidationResultDTO() {
                {
                    this.validationType = ValidationType.Schema;
                    this.schemaValidationStatus = false;
                    this.exceptionMessage = e.getMessage();
                }
            };
        }
    }

    private Schema getCreatedSchemaObj(SchemaFactory factory, Path xsdFilePath) throws SAXException {
        if (cache.containsKey(xsdFilePath)) {
            return cache.get(xsdFilePath);
        }
        Schema schema = factory.newSchema(new File(xsdFilePath.toString()));
        cache.put(xsdFilePath, schema);
        return schema;
    }
}
