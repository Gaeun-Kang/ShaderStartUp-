using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    private bool FindPlayer = false;
    private Vector3 lastknownPlayerPosition;
    void Start()
    {
        LinkInfo();
    }


    private void Update()
    {
        if(!FindPlayer)
        {
            DetectPlayer();
        }
        else
        {
            ChasePlayer();
        }
    }

    private void DetectPlayer()
    {
       
            Collider[] hitColliders = Physics.OverlapSphere(transform.position, 3f); // 10m ���� Ž��

        foreach (Collider col in hitColliders)
        {
            if (col.CompareTag("Player")) // �÷��̾ ���� �ȿ� ������
                {
                Debug.Log(gameObject.name + "��(��) �÷��̾ �߰��ߴ�!");
                FindPlayer = true;
                lastknownPlayerPosition = col.transform.position;

                // ��� ������ �÷��̾� �߰� �˸�
                EventManger.FindPlayerEvent(lastknownPlayerPosition);
                break;
            }
            else { Debug.Log("�������Դϴ�..."); }
            }
        }

    private void LinkInfo()
    {
        Debug.Log("�Ʊ��� ������ ��ũ�մϴ�.");
        EventManger.OnPlayerFind += OnPlayerDetected; //�ñ״�ó�� �����ϹǷ� ü������ �� �ִ�.
    }

    private void OnPlayerDetected(Vector3 playerPosition)
    {
        if(!FindPlayer)
        {
            Debug.Log("������ �����޾ҽ��ϴ�");
            FindPlayer = true;
            lastknownPlayerPosition = playerPosition;
        }

    }

     private void ChasePlayer()
    {
        if(FindPlayer == true)
        
        {
            Debug.Log("�߰ݳ���");
        }
       
    }

}
