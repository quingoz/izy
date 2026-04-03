<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePedidoRequest extends FormRequest
{
    public function authorize()
    {
        return auth()->check();
    }

    public function rules()
    {
        return [
            'comercio_id' => 'required|exists:comercios,id',
            'items' => 'required|array|min:1',
            'items.*.producto_id' => 'required|exists:productos,id',
            'items.*.cantidad' => 'required|integer|min:1|max:99',
            'items.*.variantes' => 'nullable|array',
            'items.*.variantes.*.name' => 'required|string',
            'items.*.variantes.*.value' => 'required',
            'items.*.variantes.*.price_usd' => 'required|numeric|min:0',
            'items.*.variantes.*.price_bs' => 'required|numeric|min:0',
            'items.*.notas' => 'nullable|string|max:500',
            
            'tipo_pago' => 'required|in:efectivo,pago_movil,transferencia,tarjeta',
            'vuelto_de' => 'nullable|required_if:tipo_pago,efectivo|numeric|min:0',
            
            'pago_movil' => 'nullable|required_if:tipo_pago,pago_movil|array',
            'pago_movil.banco' => 'required_with:pago_movil|string',
            'pago_movil.telefono' => 'required_with:pago_movil|string',
            'pago_movil.referencia' => 'required_with:pago_movil|string',
            
            'direccion' => 'required|array',
            'direccion.calle' => 'required|string',
            'direccion.ciudad' => 'nullable|string',
            'direccion.estado' => 'nullable|string',
            'direccion.referencia' => 'nullable|string',
            'direccion.lat' => 'required|numeric|between:-90,90',
            'direccion.lng' => 'required|numeric|between:-180,180',
            
            'notas_cliente' => 'nullable|string|max:1000',
        ];
    }

    public function messages()
    {
        return [
            'items.required' => 'Debes agregar al menos un producto',
            'items.min' => 'Debes agregar al menos un producto',
            'vuelto_de.required_if' => 'Indica con cuánto vas a pagar',
            'direccion.lat.required' => 'Selecciona una dirección válida',
        ];
    }

    protected function prepareForValidation()
    {
        if ($this->has('notas_cliente')) {
            $this->merge([
                'notas_cliente' => strip_tags($this->notas_cliente)
            ]);
        }
    }
}
