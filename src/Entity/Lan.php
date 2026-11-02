<?php

namespace App\Entity;

use App\Repository\LanRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: LanRepository::class)]
class Lan
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 180)]
    private ?string $nom = null;

    #[ORM\Column(type: Types::TEXT)]
    private ?string $description = null;

    #[ORM\Column(length: 120)]
    private ?string $ville = null;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $adresse = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $dateDebut = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $dateFin = null;

    #[ORM\Column(length: 120)]
    private ?string $jeu = null;

    #[ORM\Column]
    private int $placesMax = 0;

    #[ORM\Column]
    private float $prix = 0;

    #[ORM\Column(length: 500, nullable: true)]
    private ?string $image = null;

    public function getId(): ?int { return $this->id; }
    public function getNom(): ?string { return $this->nom; }
    public function setNom(string $nom): static { $this->nom = $nom; return $this; }
    public function getDescription(): ?string { return $this->description; }
    public function setDescription(string $description): static { $this->description = $description; return $this; }
    public function getVille(): ?string { return $this->ville; }
    public function setVille(string $ville): static { $this->ville = $ville; return $this; }
    public function getAdresse(): ?string { return $this->adresse; }
    public function setAdresse(?string $adresse): static { $this->adresse = $adresse; return $this; }
    public function getDateDebut(): ?\DateTimeImmutable { return $this->dateDebut; }
    public function setDateDebut(\DateTimeImmutable $dateDebut): static { $this->dateDebut = $dateDebut; return $this; }
    public function getDateFin(): ?\DateTimeImmutable { return $this->dateFin; }
    public function setDateFin(\DateTimeImmutable $dateFin): static { $this->dateFin = $dateFin; return $this; }
    public function getJeu(): ?string { return $this->jeu; }
    public function setJeu(string $jeu): static { $this->jeu = $jeu; return $this; }
    public function getPlacesMax(): int { return $this->placesMax; }
    public function setPlacesMax(int $placesMax): static { $this->placesMax = $placesMax; return $this; }
    public function getPrix(): float { return $this->prix; }
    public function setPrix(float $prix): static { $this->prix = $prix; return $this; }
    public function getImage(): ?string { return $this->image; }
    public function setImage(?string $image): static { $this->image = $image; return $this; }
}
