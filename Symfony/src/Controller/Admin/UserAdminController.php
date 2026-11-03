<?php

namespace App\Controller\Admin;

use App\Entity\RoleRequest;
use App\Entity\User;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[IsGranted('ROLE_ADMIN')]
class UserAdminController extends AbstractController
{
    private const ROLES = [
        'Utilisateur' => 'ROLE_USER',
        'Rédacteur' => 'ROLE_REDACTEUR',
        'Vérificateur' => 'ROLE_VERIFICATEUR',
        'Admin' => 'ROLE_ADMIN',
    ];

    #[Route('/admin/user', name: 'admin_user_index', methods: ['GET'])]
    public function index(
        UserRepository $repository,
        EntityManagerInterface $em
    ): Response {
        $requests = $em->getRepository(RoleRequest::class)->findBy(
            ['status' => 'En attente'],
            ['createdAt' => 'DESC']
        );

        return $this->render('admin/user/index.html.twig', [
            'users' => $repository->findBy([], ['email' => 'ASC']),
            'availableRoles' => self::ROLES,
            'requests' => $requests,
        ]);
    }

    #[Route('/admin/user/{id}/role', name: 'admin_user_role', requirements: ['id' => '\d+'], methods: ['POST'])]
    public function updateRole(
        User $user,
        Request $request,
        EntityManagerInterface $em
    ): Response {
        if (!$this->isCsrfTokenValid('role' . $user->getId(), $request->getPayload()->getString('_token'))) {
            $this->addFlash('danger', 'Jeton de sécurité invalide.');
            return $this->redirectToRoute('admin_user_index');
        }

        $role = $request->getPayload()->getString('role');

        if (!in_array($role, self::ROLES, true)) {
            $this->addFlash('danger', 'Rôle invalide.');
            return $this->redirectToRoute('admin_user_index');
        }

        $user->setRoles([$role]);
        $em->flush();

        $this->addFlash('success', 'Rôle mis à jour pour ' . $user->getEmail() . '.');

        return $this->redirectToRoute('admin_user_index');
    }

    #[Route('/admin/demande-role/{id}/accepter', name: 'admin_role_request_accept', methods: ['POST'])]
    public function acceptRequest(
        RoleRequest $roleRequest,
        Request $request,
        EntityManagerInterface $em
    ): Response {
        if (!$this->isCsrfTokenValid('accept' . $roleRequest->getId(), $request->getPayload()->getString('_token'))) {
            throw $this->createAccessDeniedException('Jeton de sécurité invalide.');
        }

        if ($roleRequest->getStatus() !== 'En attente') {
            $this->addFlash('warning', 'Cette demande a déjà été traitée.');
            return $this->redirectToRoute('admin_user_index');
        }

        $user = $roleRequest->getUser();
        $role = $roleRequest->getRole();

        if (!$user || !in_array($role, ['ROLE_REDACTEUR', 'ROLE_VERIFICATEUR'], true)) {
            throw $this->createNotFoundException('Demande invalide.');
        }

        $roles = $user->getRoles();
        $roles[] = $role;

        $user->setRoles(array_unique($roles));
        $roleRequest->setStatus('Acceptée');

        $em->flush();

        $this->addFlash('success', 'La demande a été acceptée.');

        return $this->redirectToRoute('admin_user_index');
    }

    #[Route('/admin/demande-role/{id}/refuser', name: 'admin_role_request_reject', methods: ['POST'])]
    public function rejectRequest(
        RoleRequest $roleRequest,
        Request $request,
        EntityManagerInterface $em
    ): Response {
        if (!$this->isCsrfTokenValid('reject' . $roleRequest->getId(), $request->getPayload()->getString('_token'))) {
            throw $this->createAccessDeniedException('Jeton de sécurité invalide.');
        }

        if ($roleRequest->getStatus() !== 'En attente') {
            $this->addFlash('warning', 'Cette demande a déjà été traitée.');
            return $this->redirectToRoute('admin_user_index');
        }

        $roleRequest->setStatus('Refusée');
        $em->flush();

        $this->addFlash('success', 'La demande a été refusée.');

        return $this->redirectToRoute('admin_user_index');
    }
}
