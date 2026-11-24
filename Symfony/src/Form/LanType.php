<?php

namespace App\Form;

use App\Entity\Lan;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\DateTimeType;
use Symfony\Component\Form\Extension\Core\Type\EmailType;
use Symfony\Component\Form\Extension\Core\Type\FileType;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;
use Symfony\Component\Form\Extension\Core\Type\MoneyType;
use Symfony\Component\Form\Extension\Core\Type\NumberType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints\Email;
use Symfony\Component\Validator\Constraints\File;
use Symfony\Component\Validator\Constraints\NotBlank;
use Symfony\Component\Validator\Constraints\PositiveOrZero;

class LanType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $contraintesImage = [
            new File([
                'maxSize' => '5M',
                'mimeTypes' => [
                    'image/jpeg',
                    'image/png',
                    'image/webp',
                ],
                'mimeTypesMessage' => 'Choisis une image JPG, PNG ou WebP.',
            ]),
        ];

        if (!$options['is_edit']) {
            array_unshift(
                $contraintesImage,
                new NotBlank([
                    'message' => 'Tu dois sélectionner une photo.',
                ])
            );
        }

        $builder
            ->add('nom', TextType::class, [
                'label' => 'Nom de la LAN',
                'constraints' => [new NotBlank()],
            ])
            ->add('description', TextareaType::class, [
                'label' => 'Description',
                'attr' => ['rows' => 5],
                'constraints' => [new NotBlank()],
            ])
            ->add('ville', TextType::class, [
                'label' => 'Ville',
                'constraints' => [new NotBlank()],
            ])
            ->add('adresse', TextType::class, [
                'label' => 'Adresse (facultatif)',
                'required' => false,
            ])
            ->add('dateDebut', DateTimeType::class, [
                'label' => 'Début',
                'widget' => 'single_text',
                'input' => 'datetime_immutable',
            ])
            ->add('dateFin', DateTimeType::class, [
                'label' => 'Fin',
                'widget' => 'single_text',
                'input' => 'datetime_immutable',
            ])
            ->add('jeu', TextType::class, [
                'label' => 'Jeu principal',
                'constraints' => [new NotBlank()],
            ])
            ->add('placesMax', IntegerType::class, [
                'label' => 'Nombre maximum de joueurs',
                'constraints' => [new PositiveOrZero()],
            ])
            ->add('prix', MoneyType::class, [
                'label' => 'Prix (€)',
                'currency' => 'EUR',
                'constraints' => [new PositiveOrZero()],
            ])
            ->add('imageFile', FileType::class, [
                'label' => 'Photo de la LAN',
                'mapped' => false,
                'required' => !$options['is_edit'],
                'constraints' => $contraintesImage,
                'attr' => [
                    'accept' => 'image/jpeg,image/png,image/webp',
                ],
                'help' => 'Formats acceptés : JPG, PNG et WebP. 5 Mo maximum.',
            ])
            ->add('latitude', NumberType::class, [
                'label' => 'Latitude',
                'constraints' => [new NotBlank()],
            ])
            ->add('longitude', NumberType::class, [
                'label' => 'Longitude',
                'constraints' => [new NotBlank()],
            ])
            ->add('nomContact', TextType::class, [
                'label' => 'Nom du contact',
                'constraints' => [new NotBlank()],
            ])
            ->add('emailContact', EmailType::class, [
                'label' => 'Email du contact',
                'constraints' => [
                    new NotBlank(),
                    new Email(),
                ],
            ]);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Lan::class,
            'is_edit' => false,
        ]);

        $resolver->setAllowedTypes('is_edit', 'bool');
    }
}
