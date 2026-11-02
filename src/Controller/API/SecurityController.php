<?php

namespace App\Controller\API;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Attribute\Route;

class SecurityController extends AbstractController
{
    #[Route('/api/login', name: 'api_login', methods: ['POST'])]
    public function login(): void
    {
        throw new \LogicException('Cette méthode ne doit jamais être appelée directement — interceptée par le firewall api_login.');
    }
}
