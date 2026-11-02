<?php

namespace App\Controller;

use App\Entity\User;
use App\Form\RoleRequestType;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

class AccountController extends AbstractController
{
    #[Route('/compte/demande-role', name: 'app_account_request_role', methods: ['GET', 'POST'])]
    #[IsGranted('ROLE_USER')]
    public function requestRole(
        Request $request,
        MailerInterface $mailer,
        #[Autowire('%env(ADMIN_EMAIL)%')] string $adminEmail,
    ): Response {
        $form = $this->createForm(RoleRequestType::class);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            /** @var User $user */
            $user = $this->getUser();

            $requestedRole = $form->get('role')->getData();
            $message = $form->get('message')->getData();

            $email = (new Email())
                ->from('noreply@cesi.local')
                ->to($adminEmail)
                ->subject('Demande de changement de rôle : ' . $user->getEmail())
                ->text(
                    "Utilisateur : " . $user->getEmail() .
                    "\nRôle demandé : " . $requestedRole .
                    "\nMessage : " . $message
                );

            $mailer->send($email);

            $this->addFlash('success', 'Votre demande a bien été envoyée à l\'administrateur.');

            return $this->redirectToRoute('app_account_request_role');
        }

        return $this->render('account/request_role.html.twig', [
            'form' => $form,
        ]);
    }
}
