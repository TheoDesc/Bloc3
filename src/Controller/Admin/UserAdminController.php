<?php


namespace App\Controller\Admin;

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
    public function index(UserRepository $repository): Response
    {
        return $this->render('admin/user/index.html.twig', [
            'users' => $repository->findBy([], ['email' => 'ASC']),
            'availableRoles' => self::ROLES,
        ]);
    }

    #[Route('/admin/user/{id}/role', name: 'admin_user_role', requirements: ['id' => '\d+'], methods: ['POST'])]
    public function updateRole(User $user, Request $request, EntityManagerInterface $em): Response
    {
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
}
