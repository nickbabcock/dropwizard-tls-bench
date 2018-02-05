package com.example.tls.bench;

import com.google.common.io.ByteStreams;

import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.StreamingOutput;
import java.io.InputStream;

@Path("/")
@Produces(MediaType.APPLICATION_OCTET_STREAM)
public class EchoResource {
    @POST
    public StreamingOutput echo(InputStream in) {
        return output -> ByteStreams.copy(in, output);
    }
}
