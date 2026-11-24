<?php

namespace App\Controller\Admin;

use App\Entity\Lan;
use App\Form\LanType;
use App\Repository\LanRepository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[IsGranted('ROLE_ADMIN')]
#[Route('/admin/lans')]
class LanAdminController extends AbstractController
{
    #[Route('/', name: 'admin_lan_index', methods: ['GET'])]
    public function index(LanRepository $repository): Response
    {
        return $this->render('admin/lan/index.html.twig', [
            'lans' => $repository->findBy([], ['dateDebut' => 'ASC']),
        ]);
    }

    #[Route('/search', name: 'admin_lan_search', methods: ['GET'])]
    public function search(Request $request, LanRepository $repository): Response
    {
        $recherche = $request->query->get('q', '');

        $lans = $repository->createQueryBuilder('l')
            ->where('l.nom LIKE :recherche')
            ->orWhere('l.ville LIKE :recherche')
            ->orWhere('l.jeu LIKE :recherche')
            ->setParameter('recherche', '%' . $recherche . '%')
            ->orderBy('l.dateDebut', 'ASC')
            ->getQuery()
            ->getResult();

        return $this->render('admin/lan/_rows.html.twig', [
            'lans' => $lans,
        ]);
    }

    #[Route('/new', name: 'admin_lan_new', methods: ['GET', 'POST'])]
    public function new(
        Request $request,
        EntityManagerInterface $em,
        MailerInterface $mailer,
        LoggerInterface $logger
    ): Response {
        $lan = new Lan();
        $form = $this->createForm(LanType::class, $lan);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $imageFile = $form->get('imageFile')->getData();

            if (!$imageFile instanceof UploadedFile) {
                $this->addFlash('danger', 'Tu dois sélectionner une photo.');

                return $this->render('admin/lan/form.html.twig', [
                    'form' => $form,
                    'titre' => 'Ajouter une LAN',
                    'lan' => $lan,
                ]);
            }

            $lan->setImage($this->enregistrerImage($imageFile));

            $em->persist($lan);
            $em->flush();

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

                $this->addFlash(
                    'success',
                    'La LAN a été ajoutée et le mail de confirmation a été envoyé.'
                );
            } catch (\Throwable $e) {
                $logger->error(
                    'Erreur lors de l’envoi du mail de confirmation : ' . $e->getMessage(),
                    ['exception' => $e]
                );

                $this->addFlash(
                    'warning',
                    'La LAN a été ajoutée, mais le mail n’a pas pu être envoyé.'
                );
            }

            return $this->redirectToRoute('admin_lan_index');
        }

        return $this->render('admin/lan/form.html.twig', [
            'form' => $form,
            'titre' => 'Ajouter une LAN',
            'lan' => $lan,
        ]);
    }

    #[Route('/{id}/edit', name: 'admin_lan_edit', requirements: ['id' => '\\d+'], methods: ['GET', 'POST'])]
    public function edit(
        Lan $lan,
        Request $request,
        EntityManagerInterface $em
    ): Response {
        $form = $this->createForm(LanType::class, $lan, [
            'is_edit' => true,
        ]);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $imageFile = $form->get('imageFile')->getData();

            $ancienneImage = $lan->getImage();

            if ($imageFile instanceof UploadedFile) {
                $lan->setImage($this->enregistrerImage($imageFile));
            }

            $em->flush();

            if ($imageFile instanceof UploadedFile) {
                $this->supprimerImageLocale($ancienneImage);
            }

            $this->addFlash('success', 'La LAN a été modifiée.');

            return $this->redirectToRoute('admin_lan_index');
        }

        return $this->render('admin/lan/form.html.twig', [
            'form' => $form,
            'titre' => 'Modifier une LAN',
            'lan' => $lan,
        ]);
    }

    #[Route('/{id}/delete', name: 'admin_lan_delete', requirements: ['id' => '\\d+'], methods: ['POST'])]
    public function delete(
        Lan $lan,
        Request $request,
        EntityManagerInterface $em
    ): Response {
        if ($this->isCsrfTokenValid(
            'delete-lan-' . $lan->getId(),
            $request->getPayload()->getString('_token')
        )) {
            $image = $lan->getImage();

            $em->remove($lan);
            $em->flush();

            $this->supprimerImageLocale($image);

            $this->addFlash('success', 'La LAN a été supprimée.');
        }

        return $this->redirectToRoute('admin_lan_index');
    }

    private function enregistrerImage(UploadedFile $image): string
    {
        $repertoire = $this->getParameter('kernel.project_dir') . '/public/uploads/lans';

        if (
            !is_dir($repertoire) &&
            !mkdir($repertoire, 0775, true) &&
            !is_dir($repertoire)
        ) {
            throw new \RuntimeException('Impossible de créer le dossier des images.');
        }

        $extension = $image->guessExtension();

        if (!$extension) {
            throw new \RuntimeException('Impossible de déterminer le format de cette image.');
        }

        $nomFichier = bin2hex(random_bytes(16)) . '.' . $extension;

        $image->move($repertoire, $nomFichier);

        return '/uploads/lans/' . $nomFichier;
    }

    private function supprimerImageLocale(?string $chemin): void
    {
        if (!$chemin || !str_starts_with($chemin, '/uploads/lans/')) {
            return;
        }

        $nomFichier = basename($chemin);

        $cheminComplet = $this->getParameter('kernel.project_dir')
            . '/public/uploads/lans/'
            . $nomFichier;

        if (is_file($cheminComplet)) {
            unlink($cheminComplet);
        }
    }
}
