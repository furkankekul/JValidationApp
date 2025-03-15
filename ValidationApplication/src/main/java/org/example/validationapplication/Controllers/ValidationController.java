package org.example.validationapplication.Controllers;
import net.sf.saxon.s9api.SaxonApiException;
import org.example.validationapplication.Utils.DocumentType;
import org.example.validationapplication.Utils.ValidationResultDTO;
import org.example.validationapplication.Utils.ValidationType;
import org.example.validationapplication.ValidationBase.IValidation;
import org.example.validationapplication.ValidationBase.Validation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;

@RestController
@RequestMapping(value = "/validation")
public class ValidationController {

    private final IValidation validationService;

    public ValidationController() {
        validationService = new Validation();
    }

    @Autowired
    private Environment env;

    @PostMapping(value = "/validation")
    public ValidationResultDTO Validation(@RequestParam("file") MultipartFile file,
                                          @RequestParam("documentType") DocumentType documentType,
                                          @RequestParam("validationType") ValidationType validationType) throws IOException, SaxonApiException, SAXException {

        switch (validationType) {
            case Schema:
                return validationService.schemaValidation(file, getXsdFilePath(documentType));
            case Schematron:
                return validationService.schematronValidation(file, getXsltFilePath(documentType));
            case All:
                return validationService.allValidation(file, getXsdFilePath(documentType), getXsltFilePath(documentType));
            default:
                return null;
        }
    }

    private Path getXsltFilePath(DocumentType documentType) {
        switch (documentType) {
            case EInvoice:
            case EDespatch:
            case ApplicaitonResponse:
            case ReceiptAdvice:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_ublMainXsltFilePath")));
            case EArchive:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_eArchiveXsltFilePath")));
            case Journal:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_eLedgerJournalXsltFilePath")));
            default:
                return Paths.get("");
        }
    }

    private Path getXsdFilePath(DocumentType documentType) {
        switch (documentType) {
            case EInvoice:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_XsdInvoiceFilePath")));
            case EDespatch:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_XsdDespatchAdviceFilePath")));
            case ApplicaitonResponse:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_XsdApplicationResponseFilePath")));
            case ReceiptAdvice:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_XsdReceiptAdviceFilePath")));
            case Journal:
                return Paths.get(Objects.requireNonNull(env.getProperty("env_XsdLedgerFilePath")));
            default:
                return null;

        }
    }
}
