/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.EmpleadoDAO;
import Modelos.Empleado;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */

@WebServlet(urlPatterns = {"/api/empleados", "/api/empleados/*"})
public class EmpleadoServlet extends BaseServlet {

    private final EmpleadoDAO dao = new EmpleadoDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        enviarJson(res, HttpServletResponse.SC_OK, dao.listar());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();

        if ("/login".equals(ruta)) {
            Empleado credenciales = gson.fromJson(req.getReader(), Empleado.class);
            Empleado encontrado = dao.buscarPorUsuario(credenciales.getNombreUsuario());

            if (encontrado == null) {
                enviarMensaje(res, HttpServletResponse.SC_UNAUTHORIZED, false, "Usuario no encontrado.");
                return;
            }
            if (encontrado.getBloqueado() != null && encontrado.getBloqueado() == 1) {
                enviarMensaje(res, HttpServletResponse.SC_FORBIDDEN, false, "Usuario bloqueado.");
                return;
            }
            if (encontrado.getClaveHash().equals(credenciales.getClaveHash())) {
                encontrado.setClaveHash(null);
                enviarJson(res, HttpServletResponse.SC_OK, encontrado);
            } else {
                enviarMensaje(res, HttpServletResponse.SC_UNAUTHORIZED, false, "Contraseña incorrecta.");
            }
            return;
        }

        Empleado nuevo = gson.fromJson(req.getReader(), Empleado.class);
        if (dao.insertar(nuevo)) {
            enviarMensaje(res, HttpServletResponse.SC_CREATED, true, "Empleado registrado.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error al registrar empleado.");
        }
    }
}

