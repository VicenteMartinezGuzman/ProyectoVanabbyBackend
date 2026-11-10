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

}