<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FCMService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(env('FIREBASE_CREDENTIALS'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendToUser($userId, $title, $body, $data = [])
    {
        $user = \App\Models\User::find($userId);
        
        if (!$user || !$user->fcm_token) {
            return false;
        }

        return $this->sendToToken($user->fcm_token, $title, $body, $data);
    }

    public function sendToToken($token, $title, $body, $data = [])
    {
        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->send($message);
            
            return true;
        } catch (\Exception $e) {
            logger()->error('Error enviando FCM', [
                'error' => $e->getMessage(),
                'token' => $token
            ]);
            return false;
        }
    }

    public function sendMulticast(array $tokens, $title, $body, $data = [])
    {
        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->sendMulticast($message, $tokens);
            
            return true;
        } catch (\Exception $e) {
            logger()->error('Error enviando FCM multicast', [
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}
