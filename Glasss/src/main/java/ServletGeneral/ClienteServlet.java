/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

/**
 *
 * @author vicen
 */

import Dao.ClienteDAO;
import Modelos.Cliente;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"/api/clientes", "/api/clientes/*"})
public class ClienteServlet extends BaseServlet {

    private final ClienteDAO dao = new ClienteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        enviarJson(res, HttpServletResponse.SC_OK, dao.listar());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Cliente nuevo = gson.fromJson(req.getReader(), Cliente.class);
        if (nuevo == null || nuevo.getNombre() == null || nuevo.getNombre().isBlank()) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "El nombre es obligatorio.");
            return;
        }
        if (dao.insertar(nuevo)) {
            enviarMensaje(res, HttpServletResponse.SC_CREATED, true, "Cliente registrado correctamente.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error al guardar el cliente.");
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Integer id = obtenerIdDeRuta(req);
        Cliente editado = gson.fromJson(req.getReader(), Cliente.class);
        if (id != null) {
            editado.setClienteId(id);
        }
        if (dao.actualizar(editado)) {
            enviarMensaje(res, HttpServletResponse.SC_OK, true, "Cliente actualizado.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_NOT_FOUND, false, "No se pudo actualizar el cliente.");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Integer id = obtenerIdDeRuta(req);
        if (id == null) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "Indica el ID en la URL (ej. /api/clientes/5).");
            return;
        }
        if (dao.eliminar(id)) {
            enviarMensaje(res, HttpServletResponse.SC_OK, true, "Cliente eliminado.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_NOT_FOUND, false, "Cliente no encontrado.");
        }
    }
}