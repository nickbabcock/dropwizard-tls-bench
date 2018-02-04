package com.example.tls.bench;

import io.dropwizard.Application;
import io.dropwizard.configuration.EnvironmentVariableSubstitutor;
import io.dropwizard.configuration.SubstitutingSourceProvider;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import org.eclipse.jetty.servlet.ServletHolder;
import org.conscrypt.OpenSSLProvider; 
import java.security.Security;

public class App extends Application<AppConfig> {
	static {
		Security.addProvider(new OpenSSLProvider());
	}

    public static void main(final String[] args) throws Exception {
        new App().run(args);
    }

    @Override
    public void initialize(final Bootstrap<AppConfig> bootstrap) {
        bootstrap.setConfigurationSourceProvider(
                new SubstitutingSourceProvider(bootstrap.getConfigurationSourceProvider(),
                        new EnvironmentVariableSubstitutor(true)
                )
        );
    }

    @Override
    public void run(AppConfig conf, Environment env) throws Exception {
        switch (conf.endpointType) {
            case "jersey":
                env.jersey().register(new EchoResource());
                break;
            case "servlet":
                final EchoServlet echo = new EchoServlet();
                env.getApplicationContext().addServlet(new ServletHolder(echo), "/perf");
                break;
            case "servlet-nonblocking":
                final EchoNbServlet echonb = new EchoNbServlet();
                env.getApplicationContext().addServlet(new ServletHolder(echonb), "/perf");
                break;
            default:
                throw new RuntimeException("Unexpected conf");
        }
    }
}
