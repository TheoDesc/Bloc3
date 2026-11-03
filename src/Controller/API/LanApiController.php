<?php

namespace App\Controller\API;

use App\Entity\Lan;
use App\Repository\LanRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api/lans')]
#[IsGranted('ROLE_USER')]
class LanApiController extends AbstractController
{
    #[Route('', name: 'api_lan_index', methods: ['GET'])]
    public function index(LanRepository $repository): JsonResponse
    {
        $lans = $repository->findBy([], ['dateDebut' => 'ASC']);

        $resultat = [];

        foreach ($lans as $lan) {
            $resultat[] = $this->formatLan($lan);
        }

        return $this->json($resultat);
    }

    #[Route('/{id}', name: 'api_lan_show', requirements: ['id' => '\d+'], methods: ['GET'])]
    public function show(int $id, LanRepository $repository): JsonResponse
    {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.'
            ], 404);
        }

        return $this->json($this->formatLan($lan));
    }

    #[Route('', name: 'api_lan_create', methods: ['POST'])]
    public function create(Request $request, EntityManagerInterface $entityManager): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json(['message' => 'JSON invalide.'], 400);
        }

        $champsObligatoires = [
            'nom', 'description', 'ville', 'dateDebut',
            'dateFin', 'jeu', 'placesMax', 'prix', 'image'
        ];

        foreach ($champsObligatoires as $champ) {
            if (!isset($data[$champ])) {
                return $this->json([
                    'message' => "Le champ $champ est obligatoire."
                ], 400);
            }
        }

        try {
            $lan = new Lan();

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

            $entityManager->persist($lan);
            $entityManager->flush();

            return $this->json($this->formatLan($lan), 201);

        } catch (\Exception $e) {
            return $this->json([
                'message' => 'Impossible de créer cette LAN. Vérifie les données envoyées.'
            ], 400);
        }
    }

    #[Route('/{id}', name: 'api_lan_update', requirements: ['id' => '\d+'], methods: ['PUT'])]
    public function update(
        int $id,
        Request $request,
        LanRepository $repository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.'
            ], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json(['message' => 'JSON invalide.'], 400);
        }

        $champsObligatoires = [
            'nom', 'description', 'ville', 'dateDebut',
            'dateFin', 'jeu', 'placesMax', 'prix', 'image'
        ];

        foreach ($champsObligatoires as $champ) {
            if (!isset($data[$champ])) {
                return $this->json([
                    'message' => "Le champ $champ est obligatoire."
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

        } catch (\Exception $e) {
            return $this->json([
                'message' => 'Impossible de modifier cette LAN. Vérifie les données envoyées.'
            ], 400);
        }
    }

    #[Route('/{id}', name: 'api_lan_delete', requirements: ['id' => '\d+'], methods: ['DELETE'])]
    public function delete(
        int $id,
        LanRepository $repository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $lan = $repository->find($id);

        if (!$lan) {
            return $this->json([
                'message' => 'Cette LAN est introuvable.'
            ], 404);
        }

        $entityManager->remove($lan);
        $entityManager->flush();

        return $this->json([
            'message' => 'La LAN a bien été supprimée.'
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
