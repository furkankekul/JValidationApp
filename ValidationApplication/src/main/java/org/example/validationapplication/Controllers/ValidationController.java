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

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;

@RestController
@RequestMapping(value = "/validation")
public class ValidationController {

    @Autowired
    private Environment env;

    @PostMapping(value = "/schematron")
    public ValidationResultDTO SchematronValidation(@RequestParam("file") MultipartFile file,
                                                    @RequestParam("documentType") DocumentType documentType,
                                                    @RequestParam("validationType") ValidationType validationType) throws IOException, SaxonApiException {

        Path xsltFilePath = getXsltFilePath(documentType);
        IValidation validation = new Validation();
        return validation.schematronValidation(file, xsltFilePath);
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
}
