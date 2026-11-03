<?php

namespace App\Controller;

use App\Repository\LanRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class LanController extends AbstractController
{
    #[Route('/', name: 'app_home', methods: ['GET'])]
    public function index(LanRepository $repository): Response
    {
        return $this->render('lan/index.html.twig', [
            'lans' => $repository->findBy([], ['dateDebut' => 'ASC']),
        ]);
    }

    #[Route('/lan/{id}', name: 'app_lan_show', requirements: ['id' => '\\d+'], methods: ['GET'])]
    public function show(int $id, LanRepository $repository): Response
    {
        $lan = $repository->find($id);
        if (!$lan) {
            throw $this->createNotFoundException('Cette LAN est introuvable.');
        }

        return $this->render('lan/show.html.twig', ['lan' => $lan]);
    }
}
