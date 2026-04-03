<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'role' => ['nullable', 'in:cliente,comercio,repartidor'],
            'device_name' => ['nullable', 'string']
        ];
    }

    public function messages()
    {
        return [
            'email.unique' => 'Este email ya está registrado',
            'phone.unique' => 'Este teléfono ya está registrado',
            'password.confirmed' => 'Las contraseñas no coinciden',
        ];
    }
}
