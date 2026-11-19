/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ServletGeneral;

import Dao.InventarioYRecetaDAO;
import Modelos.Ingrediente;
import Modelos.InventarioProducto;
import Modelos.LoteInventario;
import Modelos.Receta;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author vicen
 */
@WebServlet(urlPatterns = {"/api/produccion/*"})
public class InventarioRecetaServlet extends BaseServlet {

    private final InventarioYRecetaDAO dao = new InventarioYRecetaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if ("/ingredientes".equals(req.getPathInfo())) {
            enviarJson(res, 200, dao.listarIngredientes());
        } else {
            enviarMensaje(res, 404, false, "Ruta no encontrada.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String ruta = req.getPathInfo();
        boolean ok;
        switch (ruta != null ? ruta : "") {
            case "/ingredientes" -> {
                ok = dao.insertarIngrediente(gson.fromJson(req.getReader(), Ingrediente.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Ingrediente registrado." : "Error al registrar ingrediente.");
            }
            case "/lotes" -> {
                ok = dao.registrarLote(gson.fromJson(req.getReader(), LoteInventario.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Lote registrado." : "Error al registrar lote.");
            }
            case "/recetas" -> {
                ok = dao.guardarRecetaCompleta(gson.fromJson(req.getReader(), Receta.class));
                enviarMensaje(res, ok ? 201 : 500, ok, ok ? "Receta guardada." : "Error al guardar receta.");
            }
            default -> enviarMensaje(res, 404, false, "Ruta no válida.");
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if ("/stock-producto".equals(req.getPathInfo())) {
            boolean ok = dao.actualizarStockProducto(gson.fromJson(req.getReader(), InventarioProducto.class));
            enviarMensaje(res, ok ? 200 : 500, ok, ok ? "Stock actualizado." : "Error al actualizar stock.");
        } else {
            enviarMensaje(res, 404, false, "Ruta no válida.");
        }
    }
}
