package org.jboss.test.arquillian.ce.openjdk;

import org.arquillian.cube.openshift.api.OpenShiftResource;
import org.arquillian.cube.openshift.api.Template;
import org.arquillian.cube.openshift.api.TemplateParameter;
import org.jboss.arquillian.junit.Arquillian;
import org.junit.runner.RunWith;

@RunWith(Arquillian.class)
@Template(url = "file://${user.dir}/src/test/resources/openjdk18-mysql-s2i.json",
        parameters = {
                @TemplateParameter(name = "IMAGE_STREAM_NAMESPACE", value = "${kubernetes.namespace:openshift}")
        }
)
@OpenShiftResource("classpath:openjdk-app-secret.json")
public class OpenJDKMysqlTest extends OpenJDKDatabaseTest {

    public OpenJDKMysqlTest() {
        this.persistent = false;
        this.driver = "mysql";
    }
}
