/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

/**
 *
 * @author vicen
 */
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public abstract class BaseServlet extends HttpServlet {

    protected final Gson gson = new GsonBuilder()
            .setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
            .create();

    protected void prepararRespuesta(HttpServletResponse res) {
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:4200");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        prepararRespuesta(res);
        res.setStatus(HttpServletResponse.SC_OK);
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if ("PATCH".equalsIgnoreCase(req.getMethod())) {
            doPatch(req, res);
        } else {
            super.service(req, res);
        }
    }

    protected void doPatch(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        enviarMensaje(res, HttpServletResponse.SC_METHOD_NOT_ALLOWED, false, "PATCH no implementado en este recurso.");
    }

    protected void enviarJson(HttpServletResponse res, int status, Object data) throws IOException {
        prepararRespuesta(res);
        res.setStatus(status);
        PrintWriter out = res.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    protected void enviarMensaje(HttpServletResponse res, int status, boolean ok, String mensaje) throws IOException {
        prepararRespuesta(res);
        res.setStatus(status);
        PrintWriter out = res.getWriter();
        out.print("{\"ok\": " + ok + ", \"mensaje\": \"" + mensaje + "\"}");
        out.flush();
    }

    protected Integer obtenerIdDeRuta(HttpServletRequest req) {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            return null;
        }
        try {
            return Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
