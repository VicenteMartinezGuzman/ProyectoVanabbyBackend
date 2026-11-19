/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.SeguridadDAO;
import Modelos.Bloqueo;
import Modelos.RolPermiso;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/seguridad/*"})
public class SeguridadServlet extends BaseServlet {

    private final SeguridadDAO dao = new SeguridadDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        if ("/roles".equals(ruta)) {
            enviarJson(res, 200, dao.listarRoles());
        } else if ("/permisos".equals(ruta)) {
            String rolParam = req.getParameter("rolId");
            if (rolParam == null) {
                enviarMensaje(res, 400, false, "Falta el parámetro rolId.");
                return;
            }
            enviarJson(res, 200, dao.listarPermisosPorRol(Integer.parseInt(rolParam)));
        } else {
            enviarMensaje(res, 404, false, "Ruta de seguridad no encontrada.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        if ("/asignar-permiso".equals(ruta)) {
            RolPermiso rp = gson.fromJson(req.getReader(), RolPermiso.class);
            boolean ok = dao.asignarPermisoARol(rp.getRolId(), rp.getPermisoId());
            enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Permiso asignado." : "Error al asignar permiso.");
        } else if ("/bloqueos".equals(ruta)) {
            Bloqueo b = gson.fromJson(req.getReader(), Bloqueo.class);
            boolean ok = dao.registrarBloqueo(b);
            enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Bloqueo registrado." : "Error al registrar bloqueo.");
        } else {
            enviarMensaje(res, 404, false, "Ruta no válida.");
        }
    }
}
