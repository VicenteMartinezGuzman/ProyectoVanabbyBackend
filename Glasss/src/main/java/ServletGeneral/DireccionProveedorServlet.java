/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.DireccionYProveedorDAO;
import Modelos.DireccionCliente;
import Modelos.DireccionEmpleado;
import Modelos.DireccionProveedor;
import Modelos.Proveedor;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/directorio/*"})
public class DireccionProveedorServlet extends BaseServlet {

    private final DireccionYProveedorDAO dao = new DireccionYProveedorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        if ("/proveedores".equals(ruta)) {
            enviarJson(res, 200, dao.listarProveedores());
        } else if ("/direcciones-cliente".equals(ruta)) {
            String id = req.getParameter("clienteId");
            if (id == null) {
                enviarMensaje(res, 400, false, "Falta clienteId.");
                return;
            }
            enviarJson(res, 200, dao.listarDireccionesCliente(Integer.parseInt(id)));
        } else {
            enviarMensaje(res, 404, false, "Ruta no encontrada.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        boolean ok;
        switch (ruta != null ? ruta : "") {
            case "/proveedores" -> {
                ok = dao.insertarProveedor(gson.fromJson(req.getReader(), Proveedor.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Proveedor guardado." : "Error al guardar proveedor.");
            }
            case "/direcciones-cliente" -> {
                ok = dao.insertarDireccionCliente(gson.fromJson(req.getReader(), DireccionCliente.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Dirección de cliente guardada." : "Error al guardar dirección.");
            }
            case "/direcciones-empleado" -> {
                ok = dao.insertarDireccionEmpleado(gson.fromJson(req.getReader(), DireccionEmpleado.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Dirección de empleado guardada." : "Error al guardar dirección.");
            }
            case "/direcciones-proveedor" -> {
                ok = dao.insertarDireccionProveedor(gson.fromJson(req.getReader(), DireccionProveedor.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Dirección de proveedor guardada." : "Error al guardar dirección.");
            }
            default -> enviarMensaje(res, 404, false, "Ruta no válida.");
        }
    }
}