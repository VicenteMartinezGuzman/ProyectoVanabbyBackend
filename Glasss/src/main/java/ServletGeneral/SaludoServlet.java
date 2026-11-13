package ServletGeneral;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;



@WebServlet(
urlPatterns = {"/api/users", "/api/users/*"},
loadOnStartup = 1,
asyncSupported = true
)

public class SaludoServlet extends HttpServlet{
    //init()- se ejecuta UNA vez
    @Override
    public void init() throws ServletException{
    //p. ej. abrir pool de conexiones
    log("Ya entre");
    }
    // doGet()- se ejecuta POR CADA PETICIÓN GET
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException{
                res.setContentType("application/json");
                res.setCharacterEncoding("UTF-8");
                PrintWriter out=res.getWriter();
                out.print("{\"mensaje\":\"Hola desde el servlet\"}");
    }
    
    //doPost()- se ejecuta POR CADA petición POST
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException{
    String nombre=req.getParameter("nombre");
    res.setContentType("text/html; charset=UTF-8");
    res.getWriter().print("<h1>Hola,"+ nombre + "</h1>");
    }
    
    
    
    //destroy() - se ejecuta UNA vez al final
    @Override
    public void destroy(){
    //p. ej. cerrar pool de conexiones
    }

    // 3. PUT - Reemplazar / Actualizar completamente
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        enviarRespuesta(response, "PUT: Recurso actualizado por completo.");
    }

    // 4. DELETE - Eliminar
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        enviarRespuesta(response, "DELETE: Recurso eliminado.");
    }

    // 5. PATCH - Soporte manual interceptando el ciclo de vida del Servlet
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Interceptamos si el método es PATCH
        if ("PATCH".equalsIgnoreCase(request.getMethod())) {
            doPatch(request, response);
        } else {
            // Si es cualquier otro método, dejamos que el ciclo normal de HttpServlet lo maneje
            super.service(request, response);
        }
    }

    // Método personalizado para procesar PATCH (Actualización parcial)
    protected void doPatch(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        enviarRespuesta(response, "PATCH: Recurso modificado parcialmente.");
    }

    // Método auxiliar para evitar repetir código de respuesta
    private void enviarRespuesta(HttpServletResponse response, String mensaje) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"mensaje\": \"" + mensaje + "\"}");
        out.flush();
    }
}