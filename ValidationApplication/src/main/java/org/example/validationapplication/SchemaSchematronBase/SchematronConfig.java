package org.example.validationapplication.SchemaSchematronBase;

import net.sf.saxon.s9api.*;
import org.springframework.web.multipart.MultipartFile;
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

    public StringWriter getSchematronControlResult(String xmlString, MultipartFile file, XsltTransformer xsltTransformer) throws SaxonApiException {
        StringWriter stringWriter = new StringWriter();
        StringReader reader = new StringReader(xmlString);
        Serializer output = SchematronConfig.getSaxonProcessor().newSerializer(stringWriter);
        StreamSource source = new StreamSource(reader);
        source.setSystemId(file.getOriginalFilename());
        xsltTransformer.setSource(source);
        xsltTransformer.setDestination(output);
        xsltTransformer.transform();
        xsltTransformer.close();
        reader.close();
        output.close();
        return stringWriter;
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
