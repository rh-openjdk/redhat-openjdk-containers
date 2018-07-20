package org.jboss.test.arquillian.ce.openjdk;

import org.arquillian.cube.openshift.api.OpenShiftResource;
import org.arquillian.cube.openshift.api.Template;
import org.arquillian.cube.openshift.api.TemplateParameter;
import org.arquillian.cube.openshift.impl.enricher.RouteURL;
import org.jboss.arquillian.container.test.api.RunAsClient;
import org.jboss.arquillian.junit.Arquillian;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.net.URL;

@RunWith(Arquillian.class)
@Template(url = "file://${user.dir}/src/test/resources/openjdk18-web-https-s2i.json",
        parameters = {
                @TemplateParameter(name = "IMAGE_STREAM_NAMESPACE", value = "${kubernetes.namespace:openshift}"),
                @TemplateParameter(name = "HTTPS_NAME", value = "jboss"),
                @TemplateParameter(name = "HTTPS_PASSWORD", value = "mykeystorepass")})
@OpenShiftResource("classpath:openjdk-app-secret.json")
public class OpenJDKWebSecureTest extends OpenJDKTest {
    private final String MSG = "Hello World";

    @Test
    @RunAsClient
    public void testSecureRoute(@RouteURL("secure-openjdk-app") URL url) throws Exception {
        checkResponse(url.toString(), MSG);
    }

    @Test
    public void testSecureService() throws Exception {
        String host = System.getenv("SECURE_OPENJDK_APP_SERVICE_HOST");
        int port = Integer.parseInt(System.getenv("SECURE_OPENJDK_APP_SERVICE_PORT"));
        String url = "https://" + host + ":" + port;
        checkResponse(url, MSG);
    }
}
