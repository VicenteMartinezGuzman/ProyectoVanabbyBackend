/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.ProductoDAO;
import Modelos.Producto;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/productos", "/api/productos/*"})
public class ProductoServlet extends BaseServlet {

    private final ProductoDAO dao = new ProductoDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        enviarJson(res, HttpServletResponse.SC_OK, dao.listar());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Producto nuevo = gson.fromJson(req.getReader(), Producto.class);
        if (nuevo == null || nuevo.getNombre() == null || nuevo.getPrecio() == null) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "Nombre y precio son obligatorios.");
            return;
        }
        if (dao.insertar(nuevo)) {
            enviarMensaje(res, HttpServletResponse.SC_CREATED, true, "Producto guardado correctamente.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error al guardar el producto.");
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Integer id = obtenerIdDeRuta(req);
        Producto editado = gson.fromJson(req.getReader(), Producto.class);
        if (id != null) {
            editado.setProductoId(id);
        }
        if (dao.actualizar(editado)) {
            enviarMensaje(res, HttpServletResponse.SC_OK, true, "Producto actualizado.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_NOT_FOUND, false, "No se pudo actualizar el producto.");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Integer id = obtenerIdDeRuta(req);
        if (id == null) {
            enviarMensaje(res, HttpServletResponse.SC_BAD_REQUEST, false, "Indica el ID del producto en la URL.");
            return;
        }
        if (dao.eliminar(id)) {
            enviarMensaje(res, HttpServletResponse.SC_OK, true, "Producto eliminado.");
        } else {
            enviarMensaje(res, HttpServletResponse.SC_NOT_FOUND, false, "Producto no encontrado.");
        }
    }
}
