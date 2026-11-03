<?php

namespace App\Controller;

use App\Entity\RoleRequest;
use App\Entity\User;
use App\Form\RoleRequestType;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

class AccountController extends AbstractController
{
    #[Route('/compte/demande-role', name: 'app_account_request_role', methods: ['GET', 'POST'])]
    #[IsGranted('ROLE_USER')]
    public function requestRole(
        Request $request,
        EntityManagerInterface $em
    ): Response {
        $form = $this->createForm(RoleRequestType::class);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $user = $this->getUser();

            if (!$user instanceof User) {
                throw $this->createAccessDeniedException();
            }

            $roleRequest = new RoleRequest();
            $roleRequest
                ->setUser($user)
                ->setRole($form->get('role')->getData())
                ->setMessage($form->get('message')->getData());

            $em->persist($roleRequest);
            $em->flush();

            $this->addFlash('success', 'Votre demande a bien été envoyée.');

            return $this->redirectToRoute('app_account_request_role');
        }

        return $this->render('account/request_role.html.twig', [
            'form' => $form,
        ]);
    }
}
