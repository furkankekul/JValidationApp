package org.example.validationapplication.SchematronBase;

import net.sf.saxon.s9api.*;

import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;

public class SchematronConfig {
    private static final Processor saxonProcessor = new Processor(false);

    private static final SchematronConfig instance = new SchematronConfig();

    public static SchematronConfig getInstance() {
        return instance;
    }

    public static Processor getSaxonProcessor() {
        return saxonProcessor;
    }

    public XsltTransformer getSchematronConfig(Path xsltFilePath) throws IOException, SaxonApiException {
        StreamSource xsltSource = getXsltDocument(xsltFilePath);
        XsltCompiler xsltCompiler = saxonProcessor.newXsltCompiler();
        XsltExecutable xsltExecutable = xsltCompiler.compile(xsltSource);
        XsltTransformer xsltTransformer = xsltExecutable.load();
        return xsltTransformer;
    }

    public String getSchematronControlResult(String xmlString, XsltTransformer xsltTransformer) throws SaxonApiException {
        StringWriter stringWriter = new StringWriter();
        Serializer output = SchematronConfig.getSaxonProcessor().newSerializer(stringWriter);
        xsltTransformer.setSource(new StreamSource(new StringReader(xmlString)));
        xsltTransformer.setDestination(output);
        xsltTransformer.transform();
        xsltTransformer.close();
        xsltTransformer.setSource(null);
        return stringWriter.toString();
    }

    private StreamSource getXsltDocument(Path xsltFilePath) throws IOException {
        return new StreamSource(new StringReader(Files.readString(xsltFilePath.toAbsolutePath().normalize())));
    }

}
