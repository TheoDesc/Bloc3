<?php

namespace App\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints\NotBlank;

class RoleRequestType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('role', ChoiceType::class, [
                'label' => 'Rôle souhaité',
                'choices' => [
                    'Rédacteur' => 'ROLE_REDACTEUR',
                    'Vérificateur' => 'ROLE_VERIFICATEUR',
                ],
                'expanded' => true,
                'constraints' => [
                    new NotBlank(message: 'Choisissez un rôle.'),
                ],
            ])
            ->add('message', TextareaType::class, [
                'label' => 'Message (optionnel)',
                'required' => false,
                'attr' => [
                    'rows' => 4,
                    'placeholder' => 'Pourquoi souhaitez-vous ce rôle ?',
                ],
            ]);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'csrf_token_id' => 'role_request_form',
        ]);
    }
}
