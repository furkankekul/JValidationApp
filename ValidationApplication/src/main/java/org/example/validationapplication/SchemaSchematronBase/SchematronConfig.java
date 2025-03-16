package org.example.validationapplication.SchemaSchematronBase;

import net.sf.saxon.s9api.*;
import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public class SchematronConfig {

    private static final SchematronConfig instance = new SchematronConfig();

    private static final Processor saxonProcessor = new Processor(false);

    private static final XsltCompiler xsltCompiler = saxonProcessor.newXsltCompiler();

    private static final Map<Path, XsltExecutable> cache = new HashMap<>();

    public static SchematronConfig getInstance() {
        return instance;
    }

    public static Processor getSaxonProcessor() {
        return saxonProcessor;
    }

    public XsltTransformer getSchematronConfig(Path xsltFilePath) throws IOException, SaxonApiException {
        XsltExecutable xsltExecutable = getCompiledXslt(xsltFilePath);
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

    private XsltExecutable getCompiledXslt(Path xsltFilePath) throws SaxonApiException, IOException {
        if (cache.containsKey(xsltFilePath)) {
            return cache.get(xsltFilePath);
        }
        XsltExecutable xsltExecutable = xsltCompiler.compile(getXsltDocument(xsltFilePath));
        cache.put(xsltFilePath, xsltExecutable);
        return xsltExecutable;
    }

    private StreamSource getXsltDocument(Path xsltFilePath) throws IOException {
        return new StreamSource(new StringReader(Files.readString(xsltFilePath.toAbsolutePath().normalize())));
    }

}
