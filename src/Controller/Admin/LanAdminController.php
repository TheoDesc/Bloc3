<?php

namespace App\Controller\Admin;

use App\Entity\Lan;
use App\Form\LanType;
use App\Repository\LanRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
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

    #[Route('/new', name: 'admin_lan_new', methods: ['GET', 'POST'])]
    public function new(Request $request, EntityManagerInterface $em): Response
    {
        $lan = new Lan();
        $form = $this->createForm(LanType::class, $lan);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $em->persist($lan);
            $em->flush();
            $this->addFlash('success', 'La LAN a été ajoutée.');
            return $this->redirectToRoute('admin_lan_index');
        }

        return $this->render('admin/lan/form.html.twig', ['form' => $form, 'titre' => 'Ajouter une LAN']);
    }

    #[Route('/{id}/edit', name: 'admin_lan_edit', requirements: ['id' => '\\d+'], methods: ['GET', 'POST'])]
    public function edit(Lan $lan, Request $request, EntityManagerInterface $em): Response
    {
        $form = $this->createForm(LanType::class, $lan);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $em->flush();
            $this->addFlash('success', 'La LAN a été modifiée.');
            return $this->redirectToRoute('admin_lan_index');
        }

        return $this->render('admin/lan/form.html.twig', ['form' => $form, 'titre' => 'Modifier une LAN']);
    }

    #[Route('/{id}/delete', name: 'admin_lan_delete', requirements: ['id' => '\\d+'], methods: ['POST'])]
    public function delete(Lan $lan, Request $request, EntityManagerInterface $em): Response
    {
        if ($this->isCsrfTokenValid('delete-lan-'.$lan->getId(), $request->getPayload()->getString('_token'))) {
            $em->remove($lan);
            $em->flush();
            $this->addFlash('success', 'La LAN a été supprimée.');
        }

        return $this->redirectToRoute('admin_lan_index');
    }
}
