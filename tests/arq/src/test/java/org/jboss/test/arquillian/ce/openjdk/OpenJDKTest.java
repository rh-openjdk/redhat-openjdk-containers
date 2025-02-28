package org.jboss.test.arquillian.ce.openjdk;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.arquillian.cube.openshift.api.OpenShiftDynamicImageStreamResource;
import org.arquillian.cube.openshift.api.OpenShiftResource;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.logmanager.Level;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.asset.StringAsset;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.jboss.test.arquillian.ce.common.Libraries;
import org.jboss.test.arquillian.ce.common.UnsafeOkHttpClient;
import org.junit.Assert;

import java.util.logging.Logger;

@OpenShiftResource("${openshift.imageStreams}")
@OpenShiftDynamicImageStreamResource(name = "${image.stream.name}", image = "${image.stream.image}", version = "${image.stream.version}")
public abstract class OpenJDKTest {

    private Logger log = Logger.getLogger(getClass().getName());

    @Deployment
    public static WebArchive getDeployment() {
        WebArchive war = ShrinkWrap.create(WebArchive.class, "run-in-pod.war");
        war.setWebXML(new StringAsset("<web-app/>"));
        war.addClass(OpenJDKTest.class);
        war.addClass(OpenJDKWebBasicTest.class);
        war.addClass(UnsafeOkHttpClient.class);
        war.addAsLibraries(Libraries.transitive("com.squareup.okhttp3", "okhttp"));
        war.addAsLibraries(Libraries.transitive("org.jboss.logmanager", "jboss-logmanager"));
        return war;
    }

    protected void checkResponse(String url, String expected) throws Exception {
        OkHttpClient client = UnsafeOkHttpClient.getUnsafeOkHttpClient();

        Request request = new Request.Builder()
                .url(url)
                .build();

        Response response = client.newCall(request).execute();
        String responseString = response.body().string();

        log.log(Level.INFO, responseString);
        Assert.assertNotNull(responseString);
        Assert.assertEquals(expected, responseString);
    }

}
