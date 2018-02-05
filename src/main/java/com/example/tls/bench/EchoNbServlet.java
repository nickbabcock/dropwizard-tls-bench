package com.example.tls.bench;

import javax.servlet.AsyncContext;
import javax.servlet.ReadListener;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletOutputStream;
import javax.servlet.WriteListener;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicBoolean;

// Taken from https://bugs.eclipse.org/bugs/show_bug.cgi?id=458745
public class EchoNbServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        AsyncContext ctx = req.startAsync();
        Echoer echo = new Echoer(ctx);
        req.getInputStream().setReadListener(echo);
        resp.getOutputStream().setWriteListener(echo);
    }

    private class Echoer implements ReadListener, WriteListener {
        private final byte[] buffer = new byte[4096];
        private final AsyncContext asyncContext;
        private final ServletInputStream input;
        private final ServletOutputStream output;
        private final AtomicBoolean complete = new AtomicBoolean(false);

        private Echoer(AsyncContext asyncContext) throws IOException {
            this.asyncContext = asyncContext;
            this.input = asyncContext.getRequest().getInputStream();
            this.output = asyncContext.getResponse().getOutputStream();
        }

        @Override
        public void onDataAvailable() throws IOException {
            onWritePossible();
        }

        @Override
        public void onAllDataRead() throws IOException {
            onWritePossible();
        }

        @Override
        public void onWritePossible() throws IOException {
            // This method is called:
            //   1) after first registering a WriteListener (ready for first write)
            //   2) after first registering a ReadListener iff write is ready
            //   3) when a previous write completes after an output.isReady() returns false
            //   4) from an input callback

            // We should try to read, only if we are able to write!
            while (output.isReady() && input.isReady()) {
                if (input.isFinished()) {
                    if (complete.compareAndSet(false, true))
                        asyncContext.complete();
                    break;
                }

                int read = input.read(buffer);
                if (read > 0) {
                    output.write(buffer, 0, read);

                    // only continue if we can still write
                    if (!output.isReady())
                        break;
                }
            }
        }

        @Override
        public void onError(Throwable failure) {
            failure.printStackTrace();
        }
    }
}
