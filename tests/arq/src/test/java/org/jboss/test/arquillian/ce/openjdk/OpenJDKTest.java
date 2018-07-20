package org.jboss.test.arquillian.ce.openjdk;

import java.util.logging.Logger;

import org.arquillian.cube.openshift.api.OpenShiftDynamicImageStreamResource;
import org.arquillian.cube.openshift.api.OpenShiftResource;
import org.jboss.arquillian.ce.httpclient.HttpClientBuilder;
import org.jboss.arquillian.ce.httpclient.HttpClientExecuteOptions;
import org.jboss.arquillian.ce.httpclient.HttpRequest;
import org.jboss.arquillian.ce.httpclient.HttpResponse;
import org.jboss.arquillian.ce.shrinkwrap.Libraries;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.logmanager.Level;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.asset.StringAsset;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.junit.Assert;
import org.junit.runner.RunWith;

@RunWith(Arquillian.class)
@OpenShiftResource("${openshift.imageStreams}")
@OpenShiftDynamicImageStreamResource(name = "${image.stream.name}", image = "${image.stream.image}", version = "${image.stream.version}")
public class OpenJDKTest {

    private Logger log = Logger.getLogger(getClass().getName());
    private final HttpClientExecuteOptions execOptions = new HttpClientExecuteOptions.Builder().tries(3)
            .desiredStatusCode(200).delay(10).build();

    @Deployment
    public static WebArchive getDeployment() {
        WebArchive war = ShrinkWrap.create(WebArchive.class, "run-in-pod.war");
        war.setWebXML(new StringAsset("<web-app/>"));
        war.addClass(OpenJDKTest.class);
        war.addClass(OpenJDKWebBasicTest.class);
        war.addPackage(HttpClientBuilder.class.getPackage());
        war.addAsLibraries(Libraries.transitive("org.apache.httpcomponents", "httpclient"));
        return war;
    }

    protected void checkResponse(String url, String expected) throws Exception {
        HttpRequest request = HttpClientBuilder.doGET(url);
        HttpResponse response = HttpClientBuilder.untrustedConnectionClient().execute(request, execOptions);
        String responseString = response.getResponseBodyAsString();

        log.log(Level.INFO, responseString);
        Assert.assertNotNull(responseString);
        Assert.assertEquals(expected, responseString);
    }

}
