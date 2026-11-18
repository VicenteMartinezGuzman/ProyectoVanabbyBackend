/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.math.BigDecimal;

/**
 *
 * @author vicen
 */
public class Ingrediente {

    private int ingredienteId;
    private String nombre;
    private int unidadMedidaId; // FK -> unidad_medida
    private BigDecimal costoPorUnidad;

    public Ingrediente() {
    }

    public int getIngredienteId() {
        return ingredienteId;
    }

    public void setIngredienteId(int ingredienteId) {
        this.ingredienteId = ingredienteId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getUnidadMedidaId() {
        return unidadMedidaId;
    }

    public void setUnidadMedidaId(int unidadMedidaId) {
        this.unidadMedidaId = unidadMedidaId;
    }

    public BigDecimal getCostoPorUnidad() {
        return costoPorUnidad;
    }

    public void setCostoPorUnidad(BigDecimal costoPorUnidad) {
        this.costoPorUnidad = costoPorUnidad;
    }
}
