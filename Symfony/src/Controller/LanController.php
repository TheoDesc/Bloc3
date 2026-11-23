<?php

namespace App\Controller;

use App\Repository\LanRepository;
use Dompdf\Dompdf;
use Dompdf\Options;
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

    #[Route(
        '/lan/{id}',
        name: 'app_lan_show',
        requirements: ['id' => '\d+'],
        methods: ['GET']
    )]
    public function show(int $id, LanRepository $repository): Response
    {
        $lan = $repository->find($id);

        if (!$lan) {
            throw $this->createNotFoundException(
                'Cette LAN est introuvable.'
            );
        }

        return $this->render('lan/show.html.twig', [
            'lan' => $lan,
        ]);
    }

    #[Route(
        '/lan/{id}/pdf',
        name: 'app_lan_pdf',
        requirements: ['id' => '\d+'],
        methods: ['GET']
    )]
    public function pdf(int $id, LanRepository $repository): Response
    {
        $lan = $repository->find($id);

        if (!$lan) {
            throw $this->createNotFoundException(
                'Cette LAN est introuvable.'
            );
        }

        // Configuration de Dompdf.
        $options = new Options();
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', false);

        $dompdf = new Dompdf($options);

        // Génération du HTML à partir du template PDF.
        $html = $this->renderView('lan/pdf.html.twig', [
            'lan' => $lan,
        ]);

        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->setPaper('A4', 'portrait');

        // Génération du fichier PDF.
        $dompdf->render();

        return new Response(
            $dompdf->output(),
            Response::HTTP_OK,
            [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' =>
                    'attachment; filename="lan-' . $lan->getId() . '.pdf"',
                'Cache-Control' => 'private, no-store, max-age=0',
            ]
        );
    }
}
