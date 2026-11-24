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

        $options = new Options();
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', false);

        $dompdf = new Dompdf($options);

        // Récupération de la photo locale pour l'intégrer au PDF.
        $imageDataUri = $this->chargerImagePourPdf($lan->getImage());

        $html = $this->renderView('lan/pdf.html.twig', [
            'lan' => $lan,
            'imageDataUri' => $imageDataUri,
        ]);

        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->setPaper('A4', 'portrait');

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

    private function chargerImagePourPdf(?string $cheminImage): ?string
    {
        // On accepte uniquement les photos stockées par notre application.
        if (!$cheminImage || !str_starts_with($cheminImage, '/uploads/lans/')) {
            return null;
        }

        $nomFichier = basename($cheminImage);

        $dossier = $this->getParameter('kernel.project_dir')
            . '/public/uploads/lans';

        $chemin = $dossier . DIRECTORY_SEPARATOR . $nomFichier;

        $dossierReel = realpath($dossier);
        $fichierReel = realpath($chemin);

        if (
            !$dossierReel ||
            !$fichierReel ||
            !is_file($fichierReel) ||
            !str_starts_with(
                $fichierReel,
                $dossierReel . DIRECTORY_SEPARATOR
            )
        ) {
            return null;
        }

        $finfo = new \finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($fichierReel);

        // Les JPEG et PNG sont directement compatibles avec Dompdf.
        if (in_array($mime, ['image/jpeg', 'image/png'], true)) {
            $contenu = file_get_contents($fichierReel);

            if ($contenu === false) {
                return null;
            }

            return 'data:' . $mime . ';base64,' . base64_encode($contenu);
        }

        // Conversion du WebP en PNG si GD prend en charge ce format.
        if ($mime === 'image/webp' && function_exists('imagecreatefromwebp')) {
            $image = @imagecreatefromwebp($fichierReel);

            if ($image === false) {
                return null;
            }

            ob_start();
            imagepng($image);
            $contenu = ob_get_clean();

            imagedestroy($image);

            if (!$contenu) {
                return null;
            }

            return 'data:image/png;base64,' . base64_encode($contenu);
        }

        return null;
    }
}
