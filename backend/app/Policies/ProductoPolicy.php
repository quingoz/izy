<?php

namespace App\Policies;

use App\Models\Producto;
use App\Models\User;

class ProductoPolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, Producto $producto)
    {
        if ($user->role === 'comercio') {
            return $user->comercio_id === $producto->comercio_id;
        }
        return true;
    }

    public function create(User $user)
    {
        return $user->role === 'comercio';
    }

    public function update(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }

    public function delete(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }
}
