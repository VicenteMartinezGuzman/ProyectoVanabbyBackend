/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;
import java.sql.Timestamp;
/**
 *
 * @author vicen
 */
public class InventarioProducto {

    private int invProductoId;
    private int productoId; // FK -> producto
    private int stockDisponible;
    private int stockMinimo;
    private Timestamp actualizadoEn;

    public InventarioProducto() {
    }

    public int getInvProductoId() {
        return invProductoId;
    }

    public void setInvProductoId(int invProductoId) {
        this.invProductoId = invProductoId;
    }

    public int getProductoId() {
        return productoId;
    }

    public void setProductoId(int productoId) {
        this.productoId = productoId;
    }

    public int getStockDisponible() {
        return stockDisponible;
    }

    public void setStockDisponible(int stockDisponible) {
        this.stockDisponible = stockDisponible;
    }

    public int getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(int stockMinimo) {
        this.stockMinimo = stockMinimo;
    }

    public Timestamp getActualizadoEn() {
        return actualizadoEn;
    }

    public void setActualizadoEn(Timestamp actualizadoEn) {
        this.actualizadoEn = actualizadoEn;
    }
}
