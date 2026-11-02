<?php

namespace App\Form;

use App\Entity\Lan;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\DateTimeType;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;
use Symfony\Component\Form\Extension\Core\Type\MoneyType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints\Length;
use Symfony\Component\Validator\Constraints\NotBlank;
use Symfony\Component\Validator\Constraints\PositiveOrZero;

class LanType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('nom', TextType::class, ['label' => 'Nom de la LAN', 'constraints' => [new NotBlank(), new Length(max: 180)]])
            ->add('description', TextareaType::class, ['label' => 'Description', 'attr' => ['rows' => 5], 'constraints' => [new NotBlank()]])
            ->add('ville', TextType::class, ['label' => 'Ville', 'constraints' => [new NotBlank(), new Length(max: 120)]])
            ->add('adresse', TextType::class, ['label' => 'Adresse (facultatif)', 'required' => false])
            ->add('dateDebut', DateTimeType::class, ['label' => 'Début', 'widget' => 'single_text', 'input' => 'datetime_immutable'])
            ->add('dateFin', DateTimeType::class, ['label' => 'Fin', 'widget' => 'single_text', 'input' => 'datetime_immutable'])
            ->add('jeu', TextType::class, ['label' => 'Jeu principal', 'constraints' => [new NotBlank()]])
            ->add('placesMax', IntegerType::class, ['label' => 'Nombre maximum de joueurs', 'constraints' => [new PositiveOrZero()]])
            ->add('prix', MoneyType::class, ['label' => 'Prix (€)', 'currency' => 'EUR', 'constraints' => [new PositiveOrZero()]])
            ->add('image', TextType::class, ['label' => 'URL de l’image (facultatif)', 'required' => false, 'help' => 'Colle une URL d’image https://…']);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults(['data_class' => Lan::class]);
    }
}
