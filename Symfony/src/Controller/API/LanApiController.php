<?php

namespace App\Controller\API;

use App\Entity\Lan;
use App\Repository\LanRepository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api/lans')]
#[IsGranted('ROLE_USER')]
class LanApiController extends AbstractController
{
    #[Route('', name: 'api_lan_index', methods: ['GET'])]
    public function index(
        Request $request,
        LanRepository $repository
    ): JsonResponse {
        // Sans paramètres, on conserve l'ancienne réponse.
        if (!$request->query->has('page') && !$request->query->has('limit')) {
            $lans = $repository->findBy([], ['dateDebut' => 'ASC']);

            $resultat = [];

            foreach ($lans as $lan) {
                $resultat[] = $this->formatLan($lan);
            }

            return $this->json($resultat);
        }

        // Pagination : 10 LAN par défaut, maximum 50.
        $page = max(1, $request->query->getInt('page', 1));
        $limit = $request->query->getInt('limit', 10);
        $limit = min(50, max(1, $limit));

        $total = $repository->count([]);

        $lans = $repository->findBy(
            [],
            ['dateDebut' => 'ASC'],
            $limit,
            ($page - 1) * $limit
        );

        $resultat = [];

        foreach ($lans as $lan) {
            $resultat[] = $this->formatLan($lan);
        }

        return $this->json([
            'data' => $resultat,
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'hasMore' => ($page * $limit) < $total,
        ]);
    }

    #[Route(
        '/{id}',
        name: 'api_lan_show',
        requirements: ['id' => '\d+'],
        methods: ['GET']
    )]
    public function show(
        int $id,
        LanRepository $repository
    ): JsonResponse {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.',
            ], 404);
        }

        return $this->json($this->formatLan($lan));
    }

    #[Route('', name: 'api_lan_create', methods: ['POST'])]
    #[IsGranted('ROLE_REDACTEUR')]
    public function create(
        Request $request,
        EntityManagerInterface $entityManager,
        MailerInterface $mailer,
        LoggerInterface $logger
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json([
                'message' => 'JSON invalide.',
            ], 400);
        }

        $champsObligatoires = [
            'nom',
            'description',
            'ville',
            'dateDebut',
            'dateFin',
            'jeu',
            'placesMax',
            'prix',
            'image',
            'latitude',
            'longitude',
            'nomContact',
            'emailContact',
        ];

        foreach ($champsObligatoires as $champ) {
            if (
                !array_key_exists($champ, $data) ||
                $data[$champ] === null ||
                (is_string($data[$champ]) && trim($data[$champ]) === '')
            ) {
                return $this->json([
                    'message' => "Le champ $champ est obligatoire.",
                ], 400);
            }
        }

        if (!filter_var($data['emailContact'], FILTER_VALIDATE_EMAIL)) {
            return $this->json([
                'message' => 'Adresse e-mail invalide.',
            ], 400);
        }

        if (filter_var($data['placesMax'], FILTER_VALIDATE_INT) === false) {
            return $this->json([
                'message' => 'Le nombre de places doit être un entier.',
            ], 400);
        }

        if (!is_numeric($data['prix'])) {
            return $this->json([
                'message' => 'Le prix doit être numérique.',
            ], 400);
        }

        if (!is_numeric($data['latitude']) || !is_numeric($data['longitude'])) {
            return $this->json([
                'message' => 'Les coordonnées GPS sont invalides.',
            ], 400);
        }

        $latitude = (float) $data['latitude'];
        $longitude = (float) $data['longitude'];

        if (
            $latitude < -90 || $latitude > 90 ||
            $longitude < -180 || $longitude > 180
        ) {
            return $this->json([
                'message' => 'Les coordonnées GPS sont hors limites.',
            ], 400);
        }

        try {
            $lan = new Lan();

            $lan->setNom(trim($data['nom']));
            $lan->setDescription($data['description']);
            $lan->setVille(trim($data['ville']));
            $lan->setAdresse($data['adresse'] ?? null);
            $lan->setDateDebut(new \DateTimeImmutable($data['dateDebut']));
            $lan->setDateFin(new \DateTimeImmutable($data['dateFin']));
            $lan->setJeu(trim($data['jeu']));
            $lan->setPlacesMax((int) $data['placesMax']);
            $lan->setPrix((float) $data['prix']);
            $lan->setImage(trim($data['image']));
            $lan->setLatitude($latitude);
            $lan->setLongitude($longitude);
            $lan->setNomContact(trim($data['nomContact']));
            $lan->setEmailContact(trim($data['emailContact']));

            $entityManager->persist($lan);
            $entityManager->flush();

            // Envoi du mail de confirmation prévu dans le sujet.
            $emailEnvoye = false;

            try {
                $lien = $this->generateUrl(
                    'app_lan_show',
                    ['id' => $lan->getId()],
                    UrlGeneratorInterface::ABSOLUTE_URL
                );

                $email = (new Email())
                    ->from('no-reply@cesi.local')
                    ->to($lan->getEmailContact())
                    ->subject('Confirmation de création de votre LAN')
                    ->html($this->renderView('emails/lan_confirmation.html.twig', [
                        'lan' => $lan,
                        'lien' => $lien,
                    ]));

                $mailer->send($email);
                $emailEnvoye = true;
            } catch (\Throwable $e) {
                $logger->error(
                    'Erreur lors de l’envoi du mail API : ' . $e->getMessage(),
                    ['exception' => $e]
                );
            }

            return $this->json([
                ...$this->formatLan($lan),
                'emailEnvoye' => $emailEnvoye,
            ], 201);

        } catch (\Throwable $e) {
            $logger->error(
                'Erreur lors de la création d’une LAN par API : ' . $e->getMessage(),
                ['exception' => $e]
            );

            return $this->json([
                'message' => 'Impossible de créer cette LAN. Vérifie les données envoyées.',
            ], 400);
        }
    }

    #[Route(
        '/{id}',
        name: 'api_lan_update',
        requirements: ['id' => '\d+'],
        methods: ['PUT']
    )]
    #[IsGranted('ROLE_VERIFICATEUR')]
    public function update(
        int $id,
        Request $request,
        LanRepository $repository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.',
            ], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json([
                'message' => 'JSON invalide.',
            ], 400);
        }

        $champsObligatoires = [
            'nom',
            'description',
            'ville',
            'dateDebut',
            'dateFin',
            'jeu',
            'placesMax',
            'prix',
            'image',
        ];

        foreach ($champsObligatoires as $champ) {
            if (!isset($data[$champ])) {
                return $this->json([
                    'message' => "Le champ $champ est obligatoire.",
                ], 400);
            }
        }

        try {
            $lan->setNom($data['nom']);
            $lan->setDescription($data['description']);
            $lan->setVille($data['ville']);
            $lan->setAdresse($data['adresse'] ?? null);
            $lan->setDateDebut(new \DateTimeImmutable($data['dateDebut']));
            $lan->setDateFin(new \DateTimeImmutable($data['dateFin']));
            $lan->setJeu($data['jeu']);
            $lan->setPlacesMax((int) $data['placesMax']);
            $lan->setPrix((float) $data['prix']);
            $lan->setImage($data['image']);
            $lan->setLatitude(isset($data['latitude']) ? (float) $data['latitude'] : null);
            $lan->setLongitude(isset($data['longitude']) ? (float) $data['longitude'] : null);
            $lan->setNomContact($data['nomContact'] ?? null);
            $lan->setEmailContact($data['emailContact'] ?? null);

            $entityManager->flush();

            return $this->json($this->formatLan($lan));

        } catch (\Throwable $e) {
            return $this->json([
                'message' => 'Impossible de modifier cette LAN. Vérifie les données envoyées.',
            ], 400);
        }
    }

    #[Route(
        '/{id}',
        name: 'api_lan_delete',
        requirements: ['id' => '\d+'],
        methods: ['DELETE']
    )]
    #[IsGranted('ROLE_ADMIN')]
    public function delete(
        int $id,
        LanRepository $repository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.',
            ], 404);
        }

        $entityManager->remove($lan);
        $entityManager->flush();

        return $this->json([
            'message' => 'La LAN a bien été supprimée.',
        ]);
    }

    private function formatLan(Lan $lan): array
    {
        return [
            'id' => $lan->getId(),
            'nom' => $lan->getNom(),
            'description' => $lan->getDescription(),
            'ville' => $lan->getVille(),
            'adresse' => $lan->getAdresse(),
            'dateDebut' => $lan->getDateDebut()?->format('Y-m-d H:i:s'),
            'dateFin' => $lan->getDateFin()?->format('Y-m-d H:i:s'),
            'jeu' => $lan->getJeu(),
            'placesMax' => $lan->getPlacesMax(),
            'prix' => $lan->getPrix(),
            'image' => $lan->getImage(),
            'latitude' => $lan->getLatitude(),
            'longitude' => $lan->getLongitude(),
            'nomContact' => $lan->getNomContact(),
            'emailContact' => $lan->getEmailContact(),
        ];
    }
}
