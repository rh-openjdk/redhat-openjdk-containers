package org.jboss.test.arquillian.ce.openjdk;

import org.arquillian.cube.openshift.api.OpenShiftHandle;
import org.arquillian.cube.openshift.impl.enricher.RouteURL;
import org.jboss.arquillian.container.test.api.RunAsClient;
import org.jboss.arquillian.test.api.ArquillianResource;
import org.junit.Test;

import java.net.URL;
import java.util.logging.Logger;

public class OpenJDKDatabaseTest extends OpenJDKTest {

    private Logger log = Logger.getLogger(getClass().getName());

    @ArquillianResource
    OpenShiftHandle adapter;

    private final String NAME = "John";
    private final String NUMBER = "0123456789";
    private final String INSERT = "Stored " + NUMBER + " for " + NAME;
    private final String RETRIEVE = "Number for " + NAME + " is " + NUMBER;

    protected boolean persistent;
    protected String driver;

    @RouteURL("openjdk-app")
    private URL url;

    @Test
    @RunAsClient
    public void testRoute() throws Exception {
        String insert = url.toString() + "/?name=" + NAME + "&number=" + NUMBER;
        checkResponse(insert, INSERT);
        if (persistent) {
            restartPod("openjdk-app-" + driver);
        }
        String retrieve = url.toString() + "/?name=" + NAME;
        checkResponse(retrieve, RETRIEVE);
    }

    private void restartPod(String name) throws Exception {
        log.info("Scaling down " + name);
        adapter.scaleDeployment(name, 0);
        log.info("Scaling up " + name);
        adapter.scaleDeployment(name, 1);
    }
}