package com.example.tls.bench;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.dropwizard.Configuration;
import org.hibernate.validator.constraints.NotEmpty;

public class AppConfig extends Configuration {
    @NotEmpty
    @JsonProperty
    public String endpointType;
}
